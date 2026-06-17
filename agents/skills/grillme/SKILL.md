---
name: grillme
description: Interrogate a plan or design relentlessly before building — one question at a time, each with a recommended answer — walking the decision tree and resolving dependencies until you reach shared understanding. Explore the codebase to answer your own questions instead of asking. Use when the user wants to stress-test a plan or design before committing, or uses a 'grill' trigger ("grill me", "grill this plan", "grill this design", "poke holes in this").
---

# grillme

Interview the user relentlessly about every aspect of this plan or design until
you reach a shared understanding. Walk down each branch of the decision tree,
resolving dependencies between decisions one at a time. For each question, give
your recommended answer and a one-line why.

## How to grill

- **One question at a time.** Wait for the answer before asking the next. Asking
  several at once is bewildering and collapses the decision tree into noise.
- **Always recommend.** Every question carries your recommended answer (and, on
  a close call, the runner-up and the tradeoff between them). "What do you want?"
  with no recommendation is abdication, not grilling.
- **Resolve from the codebase first.** If a question can be answered by reading
  the code, configuration, or docs, go read them instead of asking. Only
  genuinely unresolvable choices — preferences, priorities, product intent —
  become questions for the user.
- **Follow the dependencies.** Order questions so an earlier answer unlocks the
  next; don't ask something whose framing depends on a decision not yet made.
- **Stop when understanding is shared,** not when you run out of questions. When
  the remaining choices are immaterial or clearly the user's call with an obvious
  default, say so and stop.

When the plan involves behavior change, one axis worth grilling is **which
behaviors actually matter to test** — you can't test everything, so pin the
critical paths now. That answer becomes the plan's TDD seam (see the `tdd`
skill).

## When to use it

Reach for `grillme` to stress-test a plan or design *before* committing to
building it — surfacing hidden assumptions, unforced ambiguity, and load-bearing
decisions while they are still cheap to change.

It composes naturally with the planning skills: grill a design first to pin down
the decisions, then hand the resolved intent to `plan` (or `improve`) to write
the handoff plan. The grill is the thinking; the plan is the record.
