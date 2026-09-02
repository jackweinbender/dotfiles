---
name: pr-description
description: Write or rewrite a pull request's title and description so it stands on its own for the reviewer deciding whether to approve, and for whoever finds it via git blame a year later. Gathers the real evidence first (commits, diff, the plan, test and lint output actually run, existing review threads), fills the repo's own PR template rather than imposing a skeleton, then gates the draft against an honesty checklist before posting. Use when opening a PR, when asked to write/fix/flesh out a PR description or title, or to retrofit a description on a PR that was opened with a stub body.
license: MIT
metadata:
  author: jack.weinbender
  version: "1.0.0"
---

# pr-description

A PR description has exactly two readers: the reviewer deciding whether to approve, and the engineer who lands on this PR from `git blame` a year from now with no memory of it. Write for those two. Everything that serves neither is padding.

The diff already says *what changed*. The description exists to carry what the diff cannot: why this and not the obvious alternative, what was deliberately left alone, what it costs, and what evidence says it works.

The conventions are in [references/conventions.md](references/conventions.md) — **read it before drafting**. This file is the procedure.

## Phase 0 — Locate the PR and its template

- **Which PR.** An argument (`#140305`, a URL, or a number) names it. No argument → the current branch's PR: `gh pr view --json number,title,body,isDraft,baseRefName,headRefName`. No PR for the branch → say so and stop; opening one is `execute`'s job or an explicit ask.
- **Read the repo's template**, and treat it as authoritative for structure: `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE.md` (both casings exist across repos; some are empty). You fill its sections — you do not replace them with your own skeleton.
- **Read the existing body.** A retrofit preserves anything the human wrote (ticket links, screenshots, demo videos); you are adding rigor, not overwriting their content.

## Phase 1 — Gather the evidence

You cannot write an honest description from the diff alone, and you must not invent the parts you're missing. Collect, in this order:

1. `git -C <path> log --reverse <base>..HEAD` — the commit messages carry the reasoning as it developed, including reversals.
2. `git -C <path> diff <base>...HEAD --stat`, then the diff itself for anything the stat makes look load-bearing.
3. **The plan, if there is one** — `~/Code/workspaces/*/plans/*.md` for this branch. Its `## Why this matters`, `Out of scope`, and `## Done criteria` map almost directly onto the description's problem statement, scope fence, and verification.
4. **Verification output you actually have.** Test counts, suite names, lint/static-analysis results from *this* session's tool results or the executor's report. If you don't have them, either run them or say plainly in the draft that they're unrun — never write a number you didn't see.
5. **Existing review threads** (`gh pr view <n> --json reviews,comments`) — the best source for "why this and not the obvious alternative", because review is usually where the obvious alternative died.

If a section of the description has no evidence behind it, the honest move is to omit the section, not to fill it with plausible prose.

## Phase 2 — Draft

Map the functions in `references/conventions.md` onto the repo template's sections. Write the title last: by then you know what the change actually is.

## Phase 3 — Gate the draft before posting

Do not skip this; it is the phase that makes the output trustworthy. Read your own draft and answer each:

- **Every number traceable?** Each count, percentage, and "passes" points at a command result you can name. Delete or qualify the rest.
- **Any adjective standing in for a measurement?** "thoroughly tested", "should be safe", "robust", "minor" — replace with the measurement or cut the sentence.
- **Any known cost omitted?** An accepted side effect, an untested path, a pre-existing failure, a follow-up that must land. A named limitation is credible; a missing one is a landmine.
- **Any task narrative left?** "as requested", "per the plan", "addresses review feedback", the order you worked in. Cut.
- **Does the title name the mechanism**, not the topic?
- **Would the six-month reader understand the stakes** from the first two sentences, without opening a file?

## Phase 4 — Post

- Write the body to a temp file and use `--body-file`; never inline a multi-paragraph body into a shell argument.
  - `gh pr edit <n> --body-file <tmp>` and, when the title changes, `--title "<title>"`.
  - Creating rather than editing: `gh pr create --draft --base <base> --title "<title>" --body-file <tmp>`.
- **Draft PR → post it.** **Non-draft PR → show the user the body and ask first.** Editing the description of a PR that is already out for review is an outward-facing change to something a human may have been reading; same posture as push discipline.
- Strip the template's HTML comments (`<!-- ... -->`) from the posted body — they're instructions to the author, not content.

## Variants

- `pr-description` → the current branch's PR.
- `pr-description <number|url>` → that PR, in the repo you're in (or the URL's repo).
- `pr-description --dry-run` → draft and gate, print, post nothing. Use when the PR is managed elsewhere.

## Why it's shaped this way

- **Evidence before prose.** Descriptions go wrong by being written from the diff and the author's intentions, which is exactly the material that produces confident, unfalsifiable claims. Gathering commits, the plan, and real test output first means the description reports rather than asserts.
- **The repo template wins.** Templates across repos disagree (some want Expected impact/Testing strategy, some want Links/How to Test, some are empty). A skill that imposed its own headings would fight every template it met and get its structure edited away.
- **The gate is a separate phase on purpose.** Honesty checks fail when they're a mood; they work when they're a list you answer after the draft exists and before it's public.
