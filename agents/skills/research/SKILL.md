---
name: research
description: Investigate a question against primary sources — official docs, source code, specs, first-party APIs — and leave a cited note behind, run as a background agent so you keep working while it reads. Recalls the memory store first and routes durable vendor or platform facts back into it. Use to research a topic, gather API or docs facts, establish how a third-party system actually behaves, or delegate reading legwork.
license: MIT
metadata:
  author: jack.weinbender
  adapted-from: mattpocock/skills (engineering/research)
  version: "1.0.0"
---

# research

Delegate reading legwork to a **background agent** so the main thread keeps
moving. The output is a cited answer whose every claim traces to the source that
owns it — not a summary of what the internet believes.

## Recall first, in the main thread

Before dispatching, read `~/Code/memory/knowledge/INDEX.md` and `rg <term>
~/Code/memory/knowledge/` for the question's subject. The store already carries a
body of vendor and platform behaviour established the hard way. When a note
answers the question, say so and stop — the research is done. When a note answers
it *partially*, pass that note to the agent as established ground so it
researches the gap rather than the whole.

## Dispatch

Spawn **one background agent** with the question, the recalled notes, and this
brief:

1. **Primary sources only.** The source that *owns* a claim: official
   documentation, the project's own source code, an RFC or spec, a first-party
   API response, a vendor's changelog or status page. A blog post, a Stack
   Overflow answer, or an AI summary is a **lead**, never a citation — follow it
   to the owning source and cite that. When the trail ends at a secondary source,
   label the claim as unverified.
2. **Prefer observation to documentation when they can disagree.** For a question
   about how a system behaves *right now* — a header a CDN actually sets, a field
   a table actually has, a flag a binary actually accepts — a captured response,
   a schema dump, or `--help` outranks the docs, which go stale. Cite the
   observation and the command that produced it.
3. **Cite every claim inline**, with a URL, a `file:line`, or the command whose
   output established it. An uncited sentence is an opinion.
4. **Report the gaps as gaps.** A question the sources do not settle is reported
   as unsettled, with what was searched and what would settle it. Inferring past
   a gap is the failure mode this skill exists to prevent — a confident wrong
   answer costs more than an honest "the docs don't say".
5. **Redact.** Captured responses carry auth headers, cookies, and tokens. Write
   `<REDACTED>` in their place, and quote only lines that carry the signal.

## Route the findings

The agent returns the cited answer; **you** decide where it lands, by durability:

- **Durable vendor or platform behaviour** — how a system works, a constraint, a
  gotcha, a discriminator that tells two cases apart. This outlives the question,
  so record it: `memory add --slug … --type reference --tags … --title …
  --summary …`, fill in the body from the cited findings, keep the citations, and
  commit in `memory/`.
- **Question-scoped findings** — the comparison you needed for one decision, the
  option table you will not consult again. These go in the active workspace's
  `WORKSPACE.md` (archived to `memory/log/` by `workspace complete`), or straight
  into the conversation when there is no workspace.
- **A repo's own convention or API surface** — into that repo's docs where it
  already keeps such notes, if it does.

Keep the citations wherever it lands. A note whose claims cannot be re-checked in
a year is a note you will not trust in a year.

## Where it sits

`research` feeds the thinking rather than replacing it. Its output is material to
take *into* `brainstorm` or `vet`, or evidence for a `debug` hypothesis — not a
decision in itself.
