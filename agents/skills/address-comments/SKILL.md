---
name: address-comments
description: Handle a pull request's open review comments — from humans and from review bots (cursor/bugbot, coderabbit, copilot) — end to end. Provisions (or reuses) a workspace whose worktree tracks the PR's branch, fetches every unresolved thread via gh, triages each (human comments are authoritative intent; bot findings are verified adversarially against the code before acting), then addresses them size-gated: trivial fixes applied in the worktree, substantial ones as plans targeting the PR branch and run through execute. Closes the loop autonomously — pushes, replies to each thread with what was done or why dismissed, and resolves it — then records durable bot/repo patterns to memory. Use to address PR review comments, respond to a bot review, resolve review threads, or "handle the bugbot comments".
license: MIT
metadata:
  author: jack.weinbender
  version: "1.0.0"
---

# address-comments

You take a pull request's **open review comments** — human and bot alike — and
drive them to closed: triage, fix, reply, resolve. You are an *operational*
skill (like `verify` or `code-review`), not a pipeline thinking stage, but you
**land your work through the pipeline's machinery** — a workspace + worktree for
isolation, `plan` + `execute` for substantial fixes, the `memory` loop for
learning. You do not reinvent editing or review; you route comments into the
tools that already do those well.

The one thing you own that nothing else does is **triage**: deciding, per
comment, whether it's a real fix, a question to answer, or noise to dismiss — and
holding bot findings to a higher bar than human ones.

This composes with the rest of the system: `execute` publishes a draft PR → bots
review it → `address-comments` triages that review → substantial fixes go back
through `execute` onto the same PR. The loop closes on the PR itself.

## Operating model — always from a worktree on the PR's branch

Every fix must land on the PR's existing head branch and be pushed there, so you
always work from a **workspace whose worktree tracks that branch**. The PR's
branch *is* the integration branch (in `execute`'s terms): trivial fixes are
committed to it directly; substantial-fix plans set `Target` to it and `execute`
merges them into it. There is no in-place-on-the-canonical-clone path.

The final state is invariant: a workspace-owned worktree checked out on the PR's
branch, with the PR updated and its threads resolved.

## Inputs and provisioning

- **Input:** a PR. Default to the current branch's PR (`gh pr view`); else the
  number/URL the user named.
- **Provision a worktree on the PR's branch**, in this order (stop at the first
  that holds):
  1. The current workspace already has a worktree on the PR's head branch → use it.
  2. Another local workspace has one (glob `~/Code/workspaces/*/.worktrees/<org>/*`,
     match the branch) → use that workspace.
  3. None does → stand up a **normal workspace** and a worktree on the PR's branch,
     exactly as if the PR had come from the normal flow:
     ```bash
     workspace create --name pr-<number>            # delegate dir + lifecycle to the CLI
     git -C ~/Code/github.com/<org>/<repo> fetch origin <head-branch>
     git -C ~/Code/github.com/<org>/<repo> worktree add \
       ~/Code/workspaces/pr-<number>/.worktrees/<org>/<repo>-<branchslug> \
       --track -b <head-branch> origin/<head-branch>
     ```
     (`<branchslug>` flattens `/`→`-`, per the worktree convention.)
- **Fast-forward to `origin/<head-branch>` first**, always — you address what's on
  the PR right now, not a stale local base.
- **Preflight:** `gh auth status` and a GitHub remote. If either fails, stop and
  say so — every step needs `gh`.

Provisioning is the only thing that differs by entry point; everything after is
identical. Because there's always a real workspace, the recording surfaces
(`WORKSPACE.md`, plans, memory/log on completion) always exist — nothing about
addressing comments needs a bespoke local log.

## Recall first

Before triaging, read `~/Code/memory/knowledge/INDEX.md` and any matching notes —
especially recorded **bot patterns** ("bugbot false-positives on X", "coderabbit
nitpicks import order — ignore") and this repo's conventions. Past triage
decisions are exactly what stops you re-litigating the same bot nit every PR.

## Fetch

Pull every **unresolved** thread and the issue-level comments. The exact gh
GraphQL/REST incantations are in [references/gh-queries.md](references/gh-queries.md)
— read it. You get, per thread: its `id` (to reply/resolve), `path`/`line`,
author + author type, body, and `isOutdated`.

The set of unresolved threads **is the work queue and the state** — there is no
separate status file. Resolving a thread removes it from the queue, so the skill
is idempotent and resumable: re-run after an interruption and you pick up exactly
what's left.

## Triage — the part you own

Classify every thread. The source determines the bar:

- **Human comments are authoritative intent.** Read for what the human wants:
  - `fix` — a change they're asking for. Tag a **size**: *trivial* (typo, rename,
    one-liner, obvious nit) or *substantial* (real logic/structure change, or a
    cluster of related threads).
  - `reply-only` — a question, a "why did you…", a suggestion you'll decline with
    reasoning. No code change.
  - `discuss` — genuinely ambiguous or a product call you can't make. Surface to
    the user; don't guess.
- **Bot findings are suspect — verify adversarially.** For each, run a *read-only*
  check against the actual code in the worktree whose job is to **refute** the
  finding ("is this actually reachable / actually wrong / actually true here?").
  Dispatch these as read-only subagents (`Explore`/`general-purpose`), in
  parallel when there are several. Default to skeptical: if you can't substantiate
  it, it's a false-positive. Outcomes:
  - `confirmed` → becomes a `fix` (size-tagged like a human one).
  - `false-positive` → `dismiss`, with the refutation as the reason.
  - `nitpick` → real but not worth it (style the repo doesn't enforce, micro-opt
    with no measured cost) → `dismiss` with that reason, unless trivial enough to
    just do.

Produce a triage table — one row per thread: `thread id`, source, classification,
size (for fixes), and a one-line rationale. This table drives everything after,
and each `fix` row carries the thread id(s) it will resolve.

## Address — size-gated, through the pipeline

Handle the buckets in this order so later work branches off earlier work cleanly:

1. **Trivial fixes** — apply directly in the PR-branch worktree, commit per fix
   (message referencing the comment), then **push**. If a fix changes behavior,
   add/adjust a test for it (invoke `tdd`). Doing these first means substantial
   plans branch off a tip that already includes them.
2. **Substantial fixes** — write a plan per coherent unit (one thread or a related
   cluster) using the plan template, with **`Target` set to the PR's head branch**
   so it's an *integration-branch* plan. Then run `execute` on it: it branches off
   the PR branch in its own worktree, reviews on both axes, and on approval merges
   back into the PR-branch worktree and pushes — updating the **existing** PR (it
   won't open a second one). Use `Depends on` between plans that touch the same
   file. Record each plan's thread id(s) for the close-the-loop step.
3. **reply-only / dismiss** — no code; handled entirely in the next step.

Scope discipline carries over from `execute`: two fixes touching the same file
must be sequenced (a trivial fix pushed first, or a `Depends on` edge between
plans), never applied in parallel.

## Close the loop — autonomously

Once the code is landed and pushed, close every thread without waiting for
confirmation (this autonomy is the skill's contract). Reply **before** resolving
so the rationale stays attached:

- **fixed** → reply with what changed and the commit/PR link; resolve the thread.
- **dismiss** (bot false-positive or nitpick) → reply with the **refutation /
  reason** — this is the durable, human-visible record of *why* it was safe to
  ignore, and the reason it's posted to the PR rather than buried locally — then
  resolve.
- **reply-only** → post the answer; resolve if it was a question now answered,
  leave open if it genuinely needs the human.
- **discuss** → leave open; list these for the user at the end.
- **Issue-level / review-summary bot comments** have no thread to resolve —
  respond with a new comment only if warranted, and account for them in the
  summary.

Replies and resolutions use the GraphQL mutations in the references doc. Report a
final summary: per thread, what you did; the PR URL; anything left for the user
(the `discuss` set); the diff/plan summary; and the **terminal signal** (see
*Looping to convergence*) that tells a loop whether to run again.

## Looping to convergence

One invocation is a **single pass** over the currently-unresolved set. The
recurring cycle — push fixes → the bot re-reviews the new code → new threads →
address again — is driven by the native `loop` skill, **self-paced** (omit the
interval, so the model ends the loop on convergence rather than on a clock). Don't
build a scheduler in here; this skill only has to be safe to re-enter (it is — the
PR is the state) and tell the loop when to stop.

End every pass with a **terminal signal**:

- `CONVERGED` — nothing unresolved remains except the `discuss` set. Stop.
- `PENDING` — you pushed fixes this pass, so a bot will likely re-review. Go again
  after a wait — bots re-run *asynchronously* (minutes after a push), so don't
  spin; wait a few minutes before re-fetching. The self-paced loop /
  `ScheduleWakeup` owns the actual sleep; this skill just sets the expectation.
- `NEEDS-USER` — the only things left are `discuss` items or an escalation
  (below). Stop and hand back.

**Oscillation guard.** A bot may re-flag the same thing after your fix (a genuine
disagreement), or flag something the fix introduced — without a guard you
fix-loop forever. Keep a **seen-findings ledger in `WORKSPACE.md`** across passes:
fingerprint each finding (`path` + rule id, or a hash of the body) and count
sightings. The workspace persists between loop iterations, so it is the
cross-pass memory the PR threads can't provide — a re-review posts a *new* thread,
not the old one, so the threads alone can't tell you a finding is recurring. If a
finding reappears **twice**, stop fixing it: reply once stating the disagreement
and your reasoning, leave it for the human, and fold it into `NEEDS-USER`. Never
let the same finding drive a third fix attempt.

A pass that applies no new fixes and finds nothing new is `CONVERGED` — the fixed
point. Record durable bot patterns (below) **at convergence**, not every pass.

## Record what's durable

Close the memory loop. Anything that will recur across PRs — a bot's
characteristic false-positive, a repo convention a reviewer keeps invoking, a
dismissal rationale worth reusing — propose as a `memory add` note (type
`pattern` or `convention`) and record on approval. Per-PR specifics stay in the
workspace (archived to `memory/log/` by `workspace complete`), not the knowledge
store.

## Why it's shaped this way

- **The PR is the state machine.** Unresolved threads are the queue; resolving one
  marks it done. No local status file to drift, naturally idempotent and resumable
  — which is what makes the autonomous loop safe to re-run.
- **Bots are verified, humans are trusted.** Review bots trade precision for
  recall; auto-applying their findings propagates their false-positives into your
  code and noise into the PR. The adversarial pass is the cost of letting them in
  at all. Humans get the benefit of the doubt because the cost of auto-dismissing
  a human is high.
- **Dismissals are recorded on the PR, not hidden.** An autonomously-resolved bot
  thread must carry its justification where a human reviewer can see and challenge
  it — the reply. That visibility is what makes autonomous resolution acceptable.
- **It reuses the pipeline, it doesn't fork it.** Provisioning is `workspace` +
  the worktree convention; substantial fixes are `plan` + `execute` with
  `Target` = the PR branch; learning is `memory`. The only new surface is triage,
  because nothing else does it.
- **Everything runs from a workspace-owned worktree on the PR branch.** That is
  what lets the fixes land on the PR and be pushed, and what gives the work a
  lifecycle owner (`workspace complete`/`destroy`) instead of an orphan worktree.

## Wrapping up

When the threads are closed and the user has merged the PR, hand the workspace to
`workspace complete` (distill `## Summary`, archive to `memory/log/`, remove the
worktree, propose durable notes). If you provisioned a throwaway `pr-<number>`
workspace and there's nothing to archive, `workspace destroy` is the faster exit.
