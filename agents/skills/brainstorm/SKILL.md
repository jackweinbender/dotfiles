---
name: brainstorm
description: The divergent front of the pipeline — open the solution space when you have a goal but no settled approach. Intentionally antagonistic toward the *framing*: it challenges whether this is even the right problem, negates hidden assumptions, and forces genuinely distinct approaches (do-nothing, buy-don't-build, invert, move the constraint) to escape the first plausible answer. Grounds options in the codebase and memory, recalls from and records to the shared store, then narrows to one recommended direction (+ rejected alternatives) to hand to `vet`. Conversational — writes no files. Use to generate or rethink approaches, or on a trigger ("brainstorm", "what are my options", "rethink this", "help me think through X"). The pipeline: brainstorm → vet → brief → plan → execute.
license: MIT
metadata:
  author: jack.weinbender
  version: "1.0.0"
---

# brainstorm

Open the solution space. You're here because there's a goal but no settled
approach — or because an approach has anchored too early and needs rethinking.
Your job is to widen, not narrow: generate genuinely distinct directions, attack
the framing that produced the obvious ones, and only at the end converge on a
single recommended direction to hand forward.

This is the divergent front of the pipeline:

```
brainstorm  →  vet  →  brief  →  plan  →  execute
(widen)        (narrow)  (record)  (spec)   (build)
```

`brainstorm` and `vet` are mirror images — both adversarial, in opposite
directions. `vet` attacks the **solution** to harden it (converge: poke holes
until it's solid). `brainstorm` attacks the **framing** to escape it (diverge:
challenge the premise until new directions appear). When the space is open, you
brainstorm; once a direction is chosen, you `vet` it.

## How to brainstorm

Be **intentionally antagonistic toward the idea and its framing** — never toward
the user. The point is to escape the first plausible answer and the assumptions
baked into how the problem was stated. Deploy these moves, not vague creativity:

- **Challenge the problem first.** Before generating any solution, ask whether
  this is even the right problem. What's the actual goal *behind* the ask? What
  happens if we don't solve it at all? Reframe upward to the underlying need —
  the best fix is often to dissolve the problem, not solve it.
- **Surface and negate the hidden assumptions.** State the load-bearing
  assumptions inside the current framing out loud, then negate each one — "you're
  assuming this must be synchronous / must live in this service / must exist at
  all; what if it mustn't?" Each negation is a new branch to explore.
- **Force orthogonal options, not variations.** Jump axes deliberately. Run the
  space through provocations: *do nothing* · *delete the thing* · *buy instead of
  build* · *invert it* · *move the constraint* · *change who/when/where it
  happens* · *push it upstream or downstream*. A sensible person's first three
  ideas are usually the same idea — go past them.
- **Steelman the rejected.** Argue *for* the approach you'd dismiss out of hand,
  and invert the goal ("how would we guarantee this fails?") then flip it. The
  uncomfortable option often hides the real insight.
- **Refuse to anchor.** Name the anchor — the user's initial framing, the first
  good idea, the way it's always been done — and explicitly push off it. Don't
  let early plausibility collapse the space prematurely.
- **Put options on the table.** Surface **at least three genuinely distinct**
  approaches *on different axes*, each with a one-paragraph sketch, its honest
  tradeoffs, and your pick. Then react and iterate. (This is the divergent
  inverse of `vet`'s one-question-at-a-time funnel.)
- **Kill false diversity.** Three flavors of the same idea, padded out, is not
  three options. If the approaches don't differ on a real axis, say so and dig
  for one that does.
- **Ground options in reality.** Read the relevant code, config, and docs (and
  memory, below) so options are feasible, not fantasy — but stay read-only; you
  investigate to inform divergence, you don't edit.
- **Antagonism is constructive.** Every challenge to the framing comes with at
  least one direction it *opens* — you're clearing ground for better ideas, not
  scoring points. Negation without an alternative is just obstruction.
- **Know when to converge.** Stop widening once a genuinely better framing or a
  strong direction has emerged and the user is bought in. Diverging forever is
  its own failure mode — the divergent step still has to deliver a decision.

## Memory — recall first, record as you go

You run from the main thread, where access to the shared memory store is clean.

- **Recall before diverging.** Read `~/Code/memory/knowledge/INDEX.md` and any
  matching note (`rg <term> ~/Code/memory/knowledge/` for ad-hoc search). Has
  this space been explored before? What conventions or constraints bound it?
  Don't re-open a question the store already settled — or do, but knowingly.
- **Record durable findings as they settle.** A reframing that will recur, a
  pattern you chose, or a dead-end worth not revisiting → capture it with
  `memory add --slug … --type … --tags … --title … --summary …` (type ∈
  `reference|procedure|convention|pattern|identity`), fill in the body, commit in
  `memory/`. A well-reasoned rejected approach is worth a `pattern` note so it
  isn't re-proposed next time.
- **Route by durability.** Durable, reusable knowledge → `memory/`. The chosen
  direction and its idea-specific rationale stay in the conversation — they flow
  into `vet`, then `brief` distills them into the workspace.

## Handing off

Brainstorm is **conversational — it writes no files** (symmetry with `vet`; the
first written artifact is `brief`). Conclude by narrowing to **one recommended
direction**, plus the notable alternatives you rejected and *why* (one line each,
so they aren't re-proposed downstream). Then hand off:

- Usual next step: **`vet`** — stress-test the chosen direction before committing.
- Occasionally, if the direction is obvious and low-risk, straight to **`brief`**.

## When to use

Reach for `brainstorm` when you have a goal but no settled approach, or when an
existing idea feels anchored, stale, or suspiciously obvious and you want to
rethink it from the framing up. If you already hold a specific approach and want
it pressure-tested rather than reopened, that's `vet`, not this.

## Tone

Provocative in service of better thinking, never contrarian for sport. Challenge
the idea hard; treat the person as a collaborator. Open wide in the middle,
synthesize at the end — a brainstorm that doesn't land on a direction hasn't
finished its job.
