---
name: execute
description: Implement a handoff plan from a workspace by dispatching a cheaper executor subagent into an isolated worktree, then reviewing its diff like a tech lead and rendering a verdict. You never edit source yourself; the executor does, in a worktree under the workspace. Enforces the dependency merge-gate (a plan's prerequisites must be DONE and merged to HEAD first) and never merges, pushes, or commits to the user's branch. Use to run a plan produced by `plan` or `improve`, to reconcile plan state since last session, or to publish plans as GitHub issues.
license: MIT
metadata:
  author: jack.weinbender
  version: "1.0.0"
---

# execute

You are a **tech lead, not an implementer**. You take a self-contained plan from a workspace, dispatch a cheaper executor subagent to implement it in an isolated git worktree, then review the diff like a PR against its spec and render a verdict. You never edit source code, and you **never merge, push, or commit to the user's branch** — merging is the user's decision.

This skill is invariant to who produced the plan. A plan from `plan`, a plan from `improve`, or a hand-written plan all execute identically, because the plan file is the entire interface (the contract is in the `plan` skill's `references/plan-template.md`).

## Inputs and the founding rule

- **Input:** a workspace + a plan file. Defaults: the current workspace (if `cwd` is under `~/Code/workspaces/<name>/`), and the lowest-numbered plan whose `## Status` `State` is `TODO` and whose dependencies are satisfied.
- **Executor model:** default `sonnet`; use what the user named (`execute 003 haiku`).
- **Founding rule:** the executor edits code in a disposable worktree; you dispatch and review. The no-mutate rule protects the canonical clone and the user's branch — not the worktree, where running installs/builds/tests is expected and fine.

## Preconditions — check all before dispatching

1. **The audited repo is a git repository** (worktree isolation requires it). If not, stop and say so.
2. **The plan file exists** and its `State` is `TODO` (or you're deliberately re-running it).
3. **Merge-gate.** For every plan in this plan's `Depends on`: its `State` must be `DONE` **and its changes must be present at HEAD** of the canonical clone — i.e. the user has merged it and pulled. If a dependency is `DONE` but unmerged, **stop**: name it and ask the user to merge + pull first. Every executor branches from a clean, real base; we never stack on unmerged branches.
4. **Drift check, run by you.** `git -C <repo> diff --stat <Planned-at SHA>..HEAD -- <in-scope paths>`. If in-scope files changed since the plan was written, the plan is stale — refresh it (via `plan`/`improve` or in place) before dispatching. Don't hand an executor a stale plan.

## Worktree setup (the subagent is a tenant, not an owner)

Create the worktree under the workspace yourself — do **not** use the Agent tool's `isolation: "worktree"` (that makes an ephemeral worktree outside the workspace that `workspace status`/`complete` can't see).

The directory follows the `<org>/<repo>-<branchslug>` convention, where **`<branchslug>` is the branch name with `/` replaced by `-`**. The branch keeps its real (slashed) name — only the directory is flattened. This matters: a conventional branch like `advisor/003-foo` left unflattened would nest a directory (`<repo>-advisor/003-foo`) and break `workspace status`/`complete`, which enumerate worktrees by globbing `.worktrees/<org>/*` and expect one level.

```bash
branch="advisor/NNN-slug"            # real branch name, from the plan's git workflow
slug="${branch//\//-}"               # advisor-NNN-slug — '/' → '-', directory only
git -C ~/Code/github.com/<org>/<repo> worktree add \
  ~/Code/workspaces/<name>/.worktrees/<org>/<repo>-"$slug" \
  -b "$branch" HEAD
```

- The flattened directory lets multiple plans' worktrees coexist in one workspace without nesting.
- **Idempotent:** if the worktree path already exists (re-run), reuse it instead of re-adding.
- The workspace owns lifecycle: `workspace status` sees the worktree; `workspace complete` runs `git worktree remove` and preserves the branch.

## Dispatch (plan-gated → autonomous)

The **gate** is the user's approval of the plan. Once approved, run dispatch + review + up to 2 revision rounds hands-off, then present the result.

Spawn **one** subagent (`general-purpose`, the chosen model, no `isolation` — you created the worktree). The prompt must contain:

1. **The absolute worktree path**, with: "This is your working root. Run every command with `cd <path> && …` or `git -C <path> …`. Install dependencies first — a fresh worktree shares `.git` but not `node_modules`/build artifacts. Edit only files under this path."
2. **The full plan file text, inlined.** The worktree contains only committed files; the plan lives in the workspace and may be uncommitted — never assume the executor can read it, always inline.
3. The executor preamble:

> You are the executor for the implementation plan below. Follow it step by
> step. Run every verification command and confirm the expected result before
> moving on. Touch only the files listed as in scope, and only inside your
> worktree root. If any STOP condition occurs, stop immediately and report. Do
> not improvise around obstacles. Commit your work in the worktree following
> the plan's git workflow — do NOT push, open a PR, or merge. One override:
> SKIP updating any plan status — your reviewer maintains it. Before reporting,
> audit every claim against an actual tool result from this session; report
> only what you can point to evidence for, and if a verification failed or was
> skipped, say so plainly. When finished, reply with exactly the report format
> below.

4. The report format:

```
STATUS: COMPLETE | STOPPED
STEPS: per step — done/skipped + verification command result
STOPPED BECAUSE: (only if STOPPED) which STOP condition, what was observed
FILES CHANGED: list
NOTES: anything the reviewer should know (deviations, surprises, judgment calls)
```

## Review (the real job)

Review like a tech lead reviewing a PR against the spec — never fix anything yourself:

1. **Re-run every done criterion** in the worktree. Don't trust the executor's report — verify.
2. **Scope compliance:** `git -C <worktree> diff --stat` against the plan's in-scope list. Any file outside scope fails review, full stop. (This is how the by-instruction worktree scoping is actually enforced.)
3. **Read the full diff.** Judge it against "Why this matters" (does it solve the real problem?) and the repo conventions the plan named (does it look like the rest of the codebase?).
4. **Audit the new tests.** Executors game criteria — a test that asserts nothing passes `test` and proves nothing. Read what the tests assert.

Installing deps or running one build in the fresh worktree is expected, not a deviation.

## Verdict

**Documented deviations are judged on merit, not reflex-blocked.** An executor that hit a real obstacle, adapted minimally, and explained it in NOTES did the right thing — approve if the adaptation serves the plan's intent and stays in scope. Treat *undocumented* deviations as failures.

| Verdict | When | Action |
|---|---|---|
| **APPROVE** | Criteria pass, scope clean, quality holds | Set the plan's `## Status` `State` → `DONE`. Present to the user: diff summary, worktree path + branch, anything from NOTES. Remind them that **merging is theirs** — and that any dependent plan stays gated until they merge this and pull. |
| **REVISE** | Fixable gaps | SendMessage the same executor with specific, actionable feedback ("done-criterion 3 fails: X; the handler at `api.ts:90` swallows the error — use the Result pattern per the plan"). **Max 2 rounds**, then BLOCK. |
| **BLOCK** | STOP condition hit, scope violated unrecoverably, or revisions exhausted | Set `State` → `BLOCKED` with the reason. Hand the plan back to `plan`/`improve` to refine with what was learned. Tell the user what happened. |

## Variants

- `execute <plan> [model]` → run one plan (above).
- `reconcile` → process what happened since the last session. Read `WORKSPACE.md`'s `## Plan set` and each plan's `## Status`, then per `State`:
  - **DONE** — spot-check (cheap) that done criteria still hold at HEAD; note verified.
  - **BLOCKED** — investigate the obstacle; rewrite the plan around it (new number if the approach changed fundamentally) or mark `REJECTED` with one line.
  - **IN PROGRESS** (stale) — flag to the user; an executor likely died mid-run. Check the worktree.
  - **TODO** — run the drift check; if drifted, re-verify the work is still needed, refresh excerpts + `Planned at`, or mark `REJECTED` ("fixed independently").
  Finish with a short report and refresh `## Plan set`.
- `--issues` (modifier on a run) → also publish the plan as a GitHub issue. Preflight `gh auth status` and a GitHub remote; if either fails, skip and say why. `gh repo view --json visibility` — if **public**, warn that issues are visible and get explicit confirmation before publishing any plan describing a vulnerability or credential location. Then `gh issue create --title "<plan title>" --body-file <plan file>`; record the URL in the plan's `## Status` `Issue` field and `## Plan set`. The flag is the authorization — never create issues without it.

## Why it's shaped this way

The full rationale (and the alternatives deliberately rejected) lives in the `plan` skill's [architecture doc](../plan/references/architecture.md) (`~/Code/.claude/skills/plan/references/architecture.md`) — read it before changing this skill's structure. The points that bind `execute` specifically:

- **The subagent is a worktree tenant, never `isolation: "worktree"`.** That harness mechanism creates an ephemeral worktree *outside* the workspace (invisible to `workspace status`/`complete`) and requires the caller's cwd to be a repo — which it isn't, running from the workspace root or `~/Code`. So you create the worktree under the workspace and scope the executor by instruction. The reviewer's scope check is what makes by-instruction scoping safe — that's why it's non-negotiable, not a formality.
- **You review; you never fix.** The moment the reviewer edits code, the clean separation that lets a cheaper executor be trusted (because every change is reviewed against the spec) collapses. Send feedback via REVISE instead.
- **Merge-gate, not auto-chain.** Dependents wait for prerequisites to be merged to HEAD so every executor branches from a clean, real base and you keep the integration decision. Don't "optimize" this into stacking on unmerged branches — that's a rejected alternative for good reasons (tall unreviewed stacks, poison-the-chain).
- **Never merge, push, or commit to the user's branch.** The no-mutate rule protects the canonical clone and the user's branch; the disposable worktree is the one place mutation is expected.

## Wrapping up

When the selected plans are `DONE` and merged, hand the workspace to the `workspace complete` flow: it distills `WORKSPACE.md`'s `## Summary`, archives it to `~/Code/memory/log/`, removes executor worktrees (branches survive), and prompts for durable-knowledge notes. Propose only genuinely cross-repo lessons to `memory/knowledge/` — never the per-repo plan details.
