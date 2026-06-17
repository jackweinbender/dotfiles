# Handoff Plan Template

Every plan is written for an executor that has **zero context**: it has not seen the planning session, the audit, the other plans, or any prior conversation. It may be a smaller/cheaper model. Assume it is competent at following explicit instructions and weak at filling gaps, recovering from ambiguity, or knowing when to stop.

This is the shared contract between the `plan` skill (and the `improve` audit planner) and the `execute` skill. The plan file is the **entire interface** — the executor receives nothing else.

Three properties make a plan executable by a weaker model:

1. **Self-contained context** — everything needed is in the file: paths, code excerpts, conventions, commands.
2. **Verification gates** — every step ends with a command and its expected result. The executor never has to *judge* whether it succeeded.
3. **Hard boundaries and escape hatches** — explicit out-of-scope list, and "STOP and report" conditions instead of letting the model improvise when reality doesn't match the plan.

## Where plans live, and what is the source of truth

Plans live in the workspace, one file per unit of work:

```
~/Code/workspaces/<name>/
  WORKSPACE.md     # narrative + ## Plan set (execution order, dependency graph, rejected findings)
  plans/
    001-<slug>.md   # numbered in recommended execution order
    002-<slug>.md
  .worktrees/        # executor worktrees land here during execute
```

**Each plan's `## Status` block is the single source of truth for that plan's live state** (`State`) and its prerequisites (`Depends on`). There is no central status table — `WORKSPACE.md`'s `## Plan set` is a *derived* human-readable view of order and dependencies; if it ever disagrees with the plan files, the plan files win. The executor updates **only its own plan's** `## Status` when done.

File naming: `plans/NNN-short-slug.md`, numbered in recommended execution order.

---

## Template

```markdown
# Plan NNN: <Imperative title — what will be true after this plan>

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, set this plan's `## Status` → `State`
> to DONE — unless a reviewer dispatched you and told you they maintain status.
>
> **Drift check (run first)**: `git -C <audited repo path> diff --stat <planned-at SHA>..HEAD -- <in-scope paths>`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **State**: TODO | IN PROGRESS | DONE | BLOCKED (one-line reason) | REJECTED (one-line rationale)
- **Priority**: P1 | P2 | P3
- **Effort**: S | M | L
- **Risk**: LOW | MED | HIGH
- **Depends on**: 002, 003 (plan numbers — or "none"). The executor for THIS plan
  branches from current HEAD; every plan listed here must already be DONE **and
  merged to HEAD** before this plan is dispatched (the execute skill enforces
  this merge-gate). If two plans share an in-scope file, one must depend on the
  other — they cannot be executed independently.
- **Category**: bug | security | perf | tests | tech-debt | migration | dx | docs | direction | feature
- **Planned at**: commit `<short SHA>`, <YYYY-MM-DD> (the audited repo's HEAD when written)
- **Issue**: <GitHub issue URL — only when published via `--issues`; omit otherwise>

## Why this matters

2–5 sentences. The problem, its concrete cost, and what improves when this
lands. Written so the executor (and a human reviewer) understands the intent —
intent is what lets a correct judgment call happen when a detail is off.

## Current state

The facts the executor needs, inlined — never "as discussed" or "see the audit".
Use **absolute paths**, because the executor works in a worktree elsewhere on disk:

- The relevant files, each with one line on its role:
  - `<repo>/src/orders/api.ts` — order-list endpoint; contains the N+1 (lines 130–160)
- Excerpts of the code as it exists today (short, with `file:line` markers),
  enough that the executor can confirm it's looking at the right thing.
- The repo conventions that apply here, with a pointer to one exemplar file:
  "Error handling follows the Result pattern — see `src/lib/result.ts` and its
  use in `src/users/api.ts:40-60`. Match it."
- Any documented vocabulary or design constraints the plan must honor, inlined
  from the intent/design docs found during investigation: the relevant
  `CONTEXT.md` terms to use in names and comments, the `DESIGN.md` tokens to
  reuse, or the ADR whose decision this work must stay consistent with. Quote
  the specific lines — the executor has not read those docs.

## Commands you will need

| Purpose   | Command                  | Expected on success |
|-----------|--------------------------|---------------------|
| Install   | `pnpm install`           | exit 0              |
| Typecheck | `pnpm typecheck`         | exit 0, no errors   |
| Tests     | `pnpm test -- <filter>`  | all pass            |
| Lint      | `pnpm lint`              | exit 0              |

(Exact commands from this repo — verified during investigation, not guessed.)

## Suggested executor toolkit

(Optional — include only when relevant skills/tools plausibly exist in the
executor's environment. Skip the section otherwise.)

- Skills the executor should invoke if available, and for what.
- Reference docs worth reading before starting, by path or URL.

## Scope

**In scope** (the only files you should modify):
- `src/orders/api.ts`
- `src/orders/api.test.ts` (create)

**Out of scope** (do NOT touch, even though they look related):
- `src/orders/legacy-api.ts` — deprecated path, scheduled for deletion.
- Any change to the public response shape — clients depend on it.

## Git workflow

(Filled from investigation — match the repo's observed conventions. The execute
skill creates the worktree under the workspace's `.worktrees/`; these are the
conventions the executor commits under.)

- Branch: `advisor/NNN-<slug>` (or the repo's branch-naming convention if one is evident). Slashes are fine — `execute` flattens `/`→`-` in the worktree directory name while keeping the real branch name.
- Commit per step or per logical unit; message style: <match repo — include an example from `git log`>
- Do NOT push, open a PR, or merge to the user's branch. Merging is the operator's decision.

## Steps

### Step 1: <imperative title>

What to do, precisely. Reference exact files/symbols. Include the target code
shape when it's load-bearing.

**Verify**: `<command>` → <expected output>

### Step 2: ...

(Each step small enough to verify independently. Order steps so the codebase is
never broken between steps when possible — add new path, switch callers, then
remove old path.)

## Test plan

- **TDD**: yes (seams: <which behaviors/modules to drive test-first>) | no (why:
  <e.g. config-only, pure refactor, infra — no new behavior to specify>).
  Opt-in: logic-bearing and bug-fix plans usually say yes; set it honestly.
- **Behaviors to test** (when TDD: yes — this is the resolved planning gate the
  executor consumes, so be specific). List each as a specification through the
  **public interface**, prioritized, not a per-function checklist:
  - "rejects a checkout with an expired token" — happy path + the specific
    bug/regression this plan fixes + named edge cases.
  Drive them red→green→refactor, one at a time (see the `tdd` skill). Tests must
  assert observable behavior, not internal shape — see
  `~/Code/memory/knowledge/testing-discipline.md`.
- Which existing test to use as the structural pattern: "model after
  `src/users/api.test.ts`".
- File(s) the new tests live in.
- Verification: `<test command>` → all pass, including N new tests.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `pnpm typecheck` exits 0
- [ ] `pnpm test` exits 0; new tests for <X> exist and pass
- [ ] `grep -rn "<old pattern>" src/` returns no matches
- [ ] No files outside the in-scope list are modified (`git status`)
- [ ] This plan's `## Status` → `State` set to DONE (unless a reviewer maintains it)

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (the codebase has drifted since this plan was written).
- A step's verification fails twice after a reasonable fix attempt.
- The fix appears to require touching an out-of-scope file.
- You discover the assumption "<key assumption>" is false.

## Maintenance notes

For the human/agent who owns this code after the change lands:

- What future changes will interact with this.
- What a reviewer should scrutinize in the PR.
- Any follow-up explicitly deferred out of this plan (and why).
```

---

## Quality bar — check before finishing each plan

- Could a model that has never seen this repo execute this with only the plan file and the repo? If any step requires planning-session knowledge, inline it.
- Is every verification a command with an expected result, not a judgment ("make sure it works")?
- Does every step name exact files and symbols, not "the relevant module"?
- Are the STOP conditions specific to this plan's actual risks, not boilerplate?
- Would a reviewer reading only "Why this matters" + "Done criteria" understand what they're approving?
- No secret values anywhere in the file — locations and credential types only.
- "Planned at" SHA is filled in and the in-scope paths in the drift check match the Scope section.
- `Depends on` is honest: does any in-scope file overlap another plan's scope? If so, there must be a dependency edge between them.
