# PR title and description conventions

The standard the `pr-description` skill applies. Other skills may cite this file by path when they write a PR body. Examples are quoted from `vimeows/vimeo#140305`, `#140225`, and `#140155`.

## The title

- **Conventional-commit prefix with a scope**, lowercase after the colon, imperative, no trailing period, no ticket or PR number: `fix(session):`, `chore(cookie):`, `feat(psalm):`.
- **Name the mechanism, not the topic.** "fix(logging): resolve warehouse user from API token before session cookie" — not "fix logging bug".
- **Use the "X, not Y" contrast when the change is a correction.** It puts the entire fix in the title:
  - `fix(session): key logout revocation by (user, uniq), not (user, uniq, t)`
  - `fix(api): derive API-mode telemetry user from the API token, not the session cookie`
- Infrastructure-only work (version bumps, node pools, IAM cleanup, in-place upgrades) is `chore`, never `feat`. Reserve `feat` for net-new capability surface.
- Keep it inside ~72 characters.

## The sections

These are **functions, not headings** — map them onto whatever sections the repo's template asks for. Include a function only when you have something real to put in it; drop the rest (the `vimeows/vimeo` template says this explicitly: remove an irrelevant section, don't leave it blank, and never write "N/A").

1. **The problem, in plain terms.** Before any diff detail. State what is wrong or missing so a reader who has never opened the file understands the stakes — who is affected, and how. Name the concrete failure, not the abstraction: *"an API request authenticated as user B, sent from a browser logged in as user A, showed up in traces, logs, and experiments as user A."*
2. **What changed.** Per area, with the **mechanism**. The diff is already the file list; this is why each edit does what it does. One bolded lead-in per area.
3. **Why this and not the obvious alternative.** The approach you rejected and the reason. Include it when review changed your mind, and say so — *"Review caught that `isApi()` also returns true for any URL starting with `/api` on any host."* This is the section that most often saves the next reader from reverting you.
4. **What deliberately does NOT change.** The scope fence, and the difference between "forgot" and "decided". Name the seam you left alone and where it's handled instead (a sibling PR number, a follow-up).
5. **Known limitations / accepted side effects.** Every cost you are aware of, named. *"internal-api.vimeo.com traces lose `usr.*` entirely"* — stated, with why it's acceptable. Omitting a cost you know about is the one failure mode that destroys the description's credibility wholesale.
6. **Verification.** Evidence, under the rules below.
7. **What the reviewer is better placed to check than the code is.** The human-only asks: whether a dashboard or monitor keys on a label you changed, whether an experiment has real exposure, what production state should look like after deploy.
8. **Future maintenance.** Retirement conditions for anything transitional — the `TODO(<date>)` you left, what deletes it, and when. Also the posture for the next person who wants to extend it: *"Any PR wanting to grow the allowlist is a signal: either the factory is missing a capability, or the code genuinely needs a review-worthy exception."*

## Verification — the honesty rules

This section is where a description earns trust or loses it. Numbers, not adjectives.

- **Counts, with suite names.** "SessionTest 27/27, PlayerSessionTokenTest 13/13"; "61/61 across the three affected suites (208 assertions)". Not "tests pass".
- **Prove the bug was real, when fixing one.** Revert the production code to base, keep the new tests, show they fail: *"with production code reverted to master and the new tests kept, it fails — `resolveUser()` returns the User instead of `null`, i.e. the token demonstrably survives logout today."* A test that would pass on base proves nothing.
- **Mutation-check the tests that matter and quote what the mutation produced.** *"altering the resolver to return `0` makes it fail with 'Failed asserting that 0 is null' — it genuinely pins the behavior."*
- **Say what you did not verify, and why.** *"`_isApiModeRequest()` has no direct unit test: its only caller is the ddtrace block, and that extension isn't available in the test container."* A named gap is credible. Silence about a gap reads as a claim, and it's the claim that will be wrong.
- **Report lint/static-analysis state precisely, including failures you did not cause.** *"psalm: no new errors in changed files (the 2 reported are pre-existing `InvalidDocblock` in `QueryCached.php` / `Api/Request.php`)."*
- **Argue the fail direction by construction** whenever the change touches auth, revocation, permissions, or anything with a safety property. Not "this is safe" — the argument: *"the old-key write is unchanged and unconditional, and the new-key check only short-circuits on a positive hit … this can only revoke more, never less."*
- **Rolling-deploy safety** gets its own account when the change spans a deploy: what old readers see, what new readers see, and which direction is covered.

## Cut these

- **Task narrative.** "as requested", "per the plan", "addresses review feedback", "step 3 of the migration", the order in which you worked. The PR is the artifact, not the diary.
- **Restating the diff.** A file-by-file list that adds nothing over `--stat`.
- **Adjectival confidence.** "thoroughly tested", "should be safe", "robust", "minor change", "simple fix". Each is either a measurement you can state or a hope you should delete.
- **Measurement narratives.** How you discovered the fact belongs in the work log. State the conclusion.
- **Paraphrase of a document that exists.** Link the ADR, Notion doc, or spec; the paraphrase goes stale silently.
- **Work that belongs to a sibling PR.** Reference the number (*"Warehouse analytics logging — fixed separately in #140223"*) instead of re-explaining it.
- **Boilerplate.** Emoji, "This PR…" openers, a Description heading whose body restates the title, and any template section left empty or filled with "N/A".

## Formatting

- Backtick every symbol, file, path, header name, and config key. Bold the single load-bearing phrase in a paragraph — sparingly enough that it still means something.
- Bulleted lists with a **bolded lead-in** per bullet, for anything enumerable (areas changed, limitations, verification items).
- Reference sibling and prerequisite PRs as `#number`.
- Prose for the problem statement; bullets for everything downstream of it.
