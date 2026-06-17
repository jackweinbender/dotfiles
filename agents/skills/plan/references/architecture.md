# Architecture & Design Rationale — the plan / execute / improve system

This document is the *why* behind the `plan`, `execute`, and `improve` skills. The SKILL.md files say what to do; this says why the seams are where they are. **Read it before changing any of the three skills' structure** — several of the decisions below look like obvious cleanups to "fix" and are not. Each invariant lists what breaks if you reverse it.

## The core idea

**A plan is a self-contained unit of work, and the workspace's `plans/` directory is the interface between thinking and doing.** An expensive, high-ceiling model does the part where intelligence compounds — understanding a codebase, judging what's worth doing, specifying it precisely. A cheaper executor does the mechanical implementation. The plan file is the entire contract between them: if it's good, a model with zero context from the planning session can implement, verify, and maintain the change.

Everything else follows from taking that contract *literally*.

## The pipeline and its one seam

```
   planner  ─────────────▶  workspace/plans/*.md  ─────────────▶  executor
 (plan | improve)            (the interface)              (execute: dispatch + review)
```

- **Planners** (`plan` for a known task, `improve` for an audit) investigate read-only and write plans. They never touch source.
- **`execute`** consumes a plan, dispatches a clean-context executor subagent into an isolated worktree, and reviews the diff like a tech lead.
- The **only** thing passed between stages is files on disk. No conversation context crosses the seam — by construction.

This is why "who invoked what, from where" stopped being an isolation worry: isolation is **structural** (files), not a property of the call topology.

## Design invariants — do not "fix" these without re-reading this

1. **Plans are fully self-contained; no session context crosses the seam.**
   *Why:* the executor may be a cheaper model that never saw the planning conversation. *If reversed:* a plan that says "the pattern discussed above" silently depends on context the executor doesn't have — it fails or hallucinates. This is the founding constraint; everything below protects it.

2. **Three separate skills, not one `delegate` mega-command.**
   *Why:* the agent (or the human) is already the orchestrator; primitives compose, compound commands hide control flow where it can't be inspected, retried, or partially run. (See the memory store's *Claude Skill Composition* note.) *If reversed:* a failure mid-flow gives no visibility into which stage failed or how to resume just that stage.

3. **Each plan's `## Status` block is the single source of truth for its live `State` and `Depends on`.** `WORKSPACE.md`'s `## Plan set` is a *derived* view (order + dependency graph + rejected findings).
   *Why:* a second copy of status drifts. *If reversed:* a central index says `DONE` while the plan says `TODO` and nobody can tell which is real. If you ever want a rendered status table, generate it on demand from the plan files — never store it.

4. **Merge-gate: a dependent plan executes only once its prerequisites are `DONE` and merged to HEAD.** We never auto-stack on unmerged branches.
   *Why:* every executor branches from a clean, real base; the human merge stays the integration checkpoint ("merging is the user's decision"); small, reviewable PRs fall out for free. *If reversed (auto-chaining unmerged branches):* you get a tall stack of unreviewed branches, and one bad early plan poisons everything stacked on it.

5. **Scope-overlap forces a dependency edge; the planner serializes overlapping plans.**
   *Why:* two plans that touch the same file cannot be executed independently — the second's "Current state" excerpts drift the moment the first lands, and their branches collide on merge. Collapsing "conflict" into "ordering" lets `execute` enforce a *single* rule (deps satisfied) instead of two. *If reversed:* parallel executors on overlapping files produce conflicting diffs no one asked a human to reconcile.

6. **The executor subagent is a worktree *tenant*, not an owner. We do NOT use the Agent tool's `isolation: "worktree"`.** `execute` creates the worktree under the workspace (`.worktrees/<org>/<repo>-<branchslug>/`, where `<branchslug>` flattens `/`→`-` so a slashed branch doesn't nest a directory) with raw `git worktree add`, then hands the subagent its absolute path.
   *Why two reasons, both decisive:* (a) the harness's `isolation` worktree lives outside the workspace, so `workspace status`/`complete` can't see or clean it — it bypasses the entire workspace lifecycle we integrate with; (b) `isolation` requires the *caller's* cwd to be a git repo, but `execute` runs from the workspace root or `~/Code`, neither of which is one. *If reversed:* either workspace integration breaks, or `execute` can't run from the orchestration context at all. The cost we accept: worktree scoping is by-instruction, not hard-enforced — which is exactly what the reviewer's scope check (`git diff --stat` vs the in-scope list) exists to catch.

7. **One plan = one branch = one worktree. Parallelism is at the plan level.** No `agentid` path segment; no fan-in merge of multiple agent worktrees.
   *Why:* the plan is the unit of branching, and git physically refuses to check out one branch in two worktrees. Plans that should run in parallel are made independent (no shared scope, no dep) by the planner, so their `<repo>-<branch>` worktrees already coexist without collision. "Merge several worktrees together onto one branch" reintroduces the cross-slice conflict resolution that plan-per-branch is designed to avoid. *If reversed:* coordination/merge complexity creeps back inside a unit that was supposed to be atomic.

8. **Read-only on source everywhere except the executor's worktree. Never merge, push, or commit to the user's branch.**
   *Why:* planners advise; the executor edits only its disposable worktree; integration is the human's call. The no-mutate rule protects the canonical clone and the user's branch — not the worktree, where installs/builds/tests are expected. *If reversed:* the advisor becomes an unreviewed committer and the "you decide what merges" guarantee evaporates.

9. **Episodic vs. durable knowledge is routed deliberately.** Per-repo output (recon facts, findings, rejected items) lives in `WORKSPACE.md` → archived to `~/Code/memory/log/` on `workspace complete`. Only genuinely cross-repo lessons become `memory/knowledge/` notes.
   *Why:* the framework's knowledge store is for reusable knowledge; `workspaces/AGENTS.md` forbids per-repo task notes there. *If reversed:* the recall corpus fills with one-off findings and stops being a trustworthy map.

10. **These are prose skills — no new CLI.**
    *Why:* the work here is judgment (planning, reviewing). The deterministic, procedural bits (workspace lifecycle, worktree teardown) are already owned by the `workspace` CLI and raw `git`. *If reversed:* you'd be encoding judgment in code that can't exercise it, and fragmenting a permission surface for no gain. (If worktree *creation* logic proves fiddly, the right move is a `workspace worktree` subcommand — promote it to the existing CLI, don't grow a new one.)

11. **Invocation is explicit and the flow is cwd-aware (hybrid), not default root behavior.**
    *Why:* because isolation is structural (invariant 1), the caller's context doesn't matter — so the flow can run from root (cut a workspace, dispatch) or from inside a workspace (reuse it) identically. Keeping it opt-in avoids surprise-routing every "do X" request through plan→execute. *If reversed (auto-routing from root):* trivial requests get heavyweight orchestration the user didn't ask for.

## Deliberately rejected — don't reintroduce these

Each of these was considered and turned down for the reason given. They're listed because they're the *attractive* wrong turns.

- **A `delegate` command that does plan→execute end-to-end.** Rejected: violates primitives-over-orchestration (invariant 2). Compose the two skills instead.
- **A `plans/README.md` status index.** Rejected: duplicates per-plan status and drifts (invariant 3). Status lives in the plan; order/deps are derived in `## Plan set`.
- **Auto-chaining dependents onto unmerged dependency branches** (for a single combined PR). Rejected: tall unreviewed stacks, poison-the-chain risk; and large PRs are an anti-goal anyway (invariant 4). Merge-to-main between dependent plans is the feature, not the friction.
- **`isolation: "worktree"` for the executor.** Rejected: breaks workspace lifecycle visibility and can't run from the orchestration cwd (invariant 6).
- **`<repo>-<branch>-<agentid>` worktrees + fan-in merge.** Rejected: parallelism belongs at the plan level (invariant 7).
- **Best-of-N / tournament execution** (race several executors on one plan, pick a winner). Not rejected on principle — it's a *legitimate future mode* — but explicitly **out of the baseline**. If added, it uses an *attempt-id* segment with winner-selection (pick one, discard the rest), never a merge of attempts.

## Provenance

The `improve` skill is adapted from shadcn's `improve` (MIT). Its original `plan-template.md` became this system's shared plan contract (`plan/references/plan-template.md`); its `closing-the-loop.md` became the `execute` skill, generalized beyond audits; its repo-root `plans/` + `plans/README.md` became the workspace interface plus `WORKSPACE.md`'s `## Plan set`. The adaptations above are what make it a citizen of the `~/Code` orchestration framework rather than a standalone repo tool.
