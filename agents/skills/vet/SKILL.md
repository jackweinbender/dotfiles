---
name: vet
description: Stress-test a plan or design you already hold — interrogate it one question at a time, each with a recommended answer, walking the decision tree and resolving dependencies until you reach shared understanding. Recall from and record to the shared memory store as decisions crystallize. Explore the codebase to answer your own questions instead of asking. Use to pressure-test an idea before committing, or on a 'grill'/'vet' trigger ("grill me", "vet this", "vet this plan", "poke holes in this"). The convergent front of the pipeline: vet → brief → plan → execute.
---

# vet

Interview the user relentlessly about every aspect of this plan or design until
you reach a shared understanding. Walk down each branch of the decision tree,
resolving dependencies between decisions one at a time. For each question, give
your recommended answer and a one-line why.

This is the convergent front of the pipeline. You stress-test an idea the user
*already holds* — narrowing, pinning decisions, killing ambiguity. (Generating
options from scratch is a different, divergent move; it is not this skill.) Once
the decisions are pinned, hand the resolved intent to `brief`.

## How to vet

- **One question at a time.** Wait for the answer before asking the next. Asking
  several at once is bewildering and collapses the decision tree into noise.
- **Always recommend.** Every question carries your recommended answer (and, on
  a close call, the runner-up and the tradeoff between them). "What do you want?"
  with no recommendation is abdication, not vetting.
- **Resolve from the codebase first.** If a question can be answered by reading
  the code, configuration, or docs, go read them instead of asking. Only
  genuinely unresolvable choices — preferences, priorities, product intent —
  become questions for the user.
- **Follow the dependencies.** Order questions so an earlier answer unlocks the
  next; don't ask something whose framing depends on a decision not yet made.
- **Stop when understanding is shared,** not when you run out of questions. When
  the remaining choices are immaterial or clearly the user's call with an obvious
  default, say so and stop.

When the plan involves behavior change, one axis worth vetting is **which
behaviors actually matter to test** — you can't test everything, so pin the
critical paths now. That answer becomes the plan's TDD seam (see the `tdd`
skill), carried forward by `brief` so the planner sets it without re-deriving it.

## Memory — recall first, record as you go

You run from the main thread, where access to the shared memory store is clean.
Use it on both sides of the conversation:

- **Recall before interrogating.** Read `~/Code/memory/knowledge/INDEX.md` and
  any note matching this domain, stack, or a relevant gotcha (`rg <term>
  ~/Code/memory/knowledge/` for ad-hoc search). Vet on top of what's already
  known — don't re-litigate a convention or re-derive a fact the store records.
- **Record durable findings as they crystallize.** When the conversation settles
  something that outlives this one idea — a convention you've now decided, a
  domain fact, a gotcha, a transferable pattern — capture it with `memory add
  --slug … --type … --tags … --title … --summary …` (type ∈
  `reference|procedure|convention|pattern|identity`), fill in the body, and
  commit in `memory/`. Let `memory add` own the frontmatter and `INDEX.md`.
- **Route by durability.** Durable, reusable knowledge → `memory/`. Decisions
  specific to *this* piece of work stay in the conversation — `brief` distills
  them into the workspace, and `workspace complete` later archives them to
  `memory/log/`. Don't push idea-scoped rationale into the knowledge store.

## When to use it

Reach for `vet` to stress-test a plan or design *before* committing to building
it — surfacing hidden assumptions, unforced ambiguity, and load-bearing
decisions while they are still cheap to change.

It composes naturally with the rest of the pipeline: vet a design first to pin
down the decisions and record what's durable, then hand the resolved intent to
`brief`, which distills it into a fresh workspace for `plan` to specify. The vet
is the thinking; the brief is the record.
