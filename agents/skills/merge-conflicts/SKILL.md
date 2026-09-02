---
name: merge-conflicts
description: Resolve an in-progress merge or rebase conflict, or a PR that flipped to CONFLICTING, by tracing each side's intent to its primary source and reconciling hunk by hunk — then finish the operation and re-run the checks. Diagnoses the squash-merge artifact (no real conflict) before touching anything. Use on a conflicted merge/rebase/cherry-pick, a stacked PR gone CONFLICTING after its base merged, or "fix the conflicts".
license: MIT
metadata:
  author: jack.weinbender
  adapted-from: mattpocock/skills (engineering/resolving-merge-conflicts)
  version: "1.0.0"
---

# merge-conflicts

Work a conflict to a finished operation. You resolve by **intent** — what each
side was trying to do, traced to the source that says so — rather than by picking
lines that look right. The operation always ends finished: committed, continued,
or completed. `--abort` throws away the diagnosis you just paid for.

## Phase 0 — Diagnose before touching anything

A `CONFLICTING` PR or a conflicted rebase has two very different causes, and they
look identical. Guessing wrong is the expensive move: one needs no manual
resolution at all.

**Read `~/Code/memory/knowledge/stacked-pr-conflicting-after-base-merge.md` now**
when the trigger is a stacked PR whose base just merged. It carries both causes
with their diagnostic commands:

- **Squash-merge artifact** — the branch still holds the base PR's pre-squash
  commits, so the histories differ while the trees are identical. `git diff --stat
  <old-base-tip> origin/<default> -- <base PR's files>` returning empty confirms
  it, and `git rebase --onto origin/<default> <old-base-tip> <branch>` applies
  cleanly with **zero hunks to resolve**. Stop here; the rest of this skill does
  not apply.
- **Genuine textual overlap** — unrelated work landed in the same file region
  while the branch sat open. `git merge-tree --write-tree` emitting a real
  `CONFLICT (content)` line confirms it. Continue below.

For any other trigger, establish the state first: `git status`, the operation in
flight (`.git/MERGE_HEAD`, `rebase-merge/`, `CHERRY_PICK_HEAD`), the conflicted
paths, and what each side is (`git log --oneline <merge-base>..HEAD` and
`..MERGE_HEAD`).

**Done when** you can name which cause you have and, for a rebase, which commit
is being replayed onto what.

## Phase 1 — Trace each side's intent to its primary source

For every conflicted region, find out *why* each side made its change. The diff is
the weakest evidence available; go to the source that owns the intent:

- The commit message on each side (`git log -1 --format=%B <sha>`).
- The PR that carried it (`gh pr list --search <sha>`, then the description and
  its review threads — review is usually where the rejected alternative died).
- The plan, if the change came through this pipeline
  (`~/Code/workspaces/*/plans/*.md`).
- The issue or ticket either references.

**Done when** every conflicted region has a one-line statement of what each side
wanted, sourced from something other than the diff.

## Phase 2 — Resolve hunk by hunk

- **Preserve both intents where they are compatible.** Most conflicts are textual
  proximity, not logical opposition — two additions to the same import block, two
  cases added to the same switch. Keep both.
- **Where they are genuinely incompatible, pick the one matching the stated goal
  of the operation you are in** (the merge's purpose, the rebase's target), and
  say plainly in the commit message what the other side gave up.
- **Resolve to code that already existed on one side or the other.** Inventing new
  behaviour inside a conflict marker produces a change nobody reviewed and nobody
  is expecting; if the right answer is genuinely new code, that is a follow-up
  commit after the operation finishes, not part of the resolution.
- **Confirm removals.** When one side deleted something the other still
  references, grep for remaining use sites before honouring the delete.

**Done when** no conflict markers remain (`rg '^<<<<<<<|^>>>>>>>'` is empty) and
each resolution traces to a Phase 1 intent.

## Phase 3 — Verify, then finish

- Discover the project's real checks — typecheck, tests, lint, formatter — and run
  them. A clean-looking resolution is not behaviour-neutral; confirm it.
- Fix what the conflict broke. A test that fails only after the merge is the
  resolution's problem, not a pre-existing one — check by running it on each side.
- **Finish the operation.** Stage everything and commit the merge, or
  `git rebase --continue` until every commit is replayed. A conflict left
  half-resolved in a detached state is worse than the conflict was.

**Done when** the operation is complete, the working tree is clean, and the checks
you named have run and passed (or their failures are shown and explained).

## Afterwards, for a rewritten branch

A rebase rewrites SHAs on an already-pushed branch, so:

- `git diff --stat origin/<default> <branch>` shows exactly the originally-planned
  files — nothing gained, nothing lost.
- Push with `--force-with-lease`.
- Re-trigger any bot review; it reviewed the old SHAs.
- `mergeStateStatus: BLOCKED` afterwards is expected — required checks just need
  to re-run.
