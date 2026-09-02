---
name: debug
description: Diagnose a broken or slow system by building a tight feedback loop that goes red on the symptom, then hypothesising against it — for production incidents, service regressions, flaky tests, and bugs that resisted a first look. Recalls prior findings from the shared memory store first and records durable gotchas back. Use on "debug this", "diagnose", "why is X failing/slow/flaky", or when something is broken and the cause is not yet named. The pipeline's on-ramp: debug → (plan | fix in place).
license: MIT
metadata:
  author: jack.weinbender
  adapted-from: mattpocock/skills (engineering/diagnosing-bugs)
  version: "1.0.0"
---

# debug

A discipline for the bug that resisted a first look: the production regression, the
intermittent flake, the "it's slow and nobody knows why". Work the phases in order;
skip one only by saying out loud why it does not apply.

This is the pipeline's **on-ramp for broken things**, the mirror of `brainstorm` (which
starts from an idea). It ends in one of three places: a small fix applied in place, a
finding handed to `plan`/`improve` when the real problem is structural, or a durable
gotcha recorded to `~/Code/memory/knowledge/`.

## Recall before you dig

Read `~/Code/memory/knowledge/INDEX.md` and any note matching this service, stack, or
symptom (`rg <term> ~/Code/memory/knowledge/` for ad-hoc search). The store already
records a large body of hard-won diagnoses — a misleading error class, a tool that lies,
a topology fact. Recalling one can collapse Phase 1 to a single command.

Two notes bind almost every session here and are worth reading by name when they touch
your symptom: [[macos-fd-exhaustion-fake-tool-failures]] (local tool errors that are
lying to you) and [[git-blame-useless-after-mass-rewrite]] (history that is lying to you).

## Redact

This skill has you quote commands, outputs, and captured artifacts. Write `<REDACTED>` in
place of every secret, session value, and cookie before showing anything. Keep credentials
in environment variables so the loop can reference them without printing them. Captured
artifacts (HARs, request dumps, log lines) carry auth headers and session cookies: quote
only the lines that carry the signal.

When the redacted output is too thin to diagnose from, say so and ask.

## Phase 1: Build a loop that goes red

**This is the skill.** Everything after it is mechanical. Hold a **tight** pass/fail signal
— one that goes red on *this* symptom — and bisection, hypothesis-testing, and
instrumentation all just consume it. Without one, reading code produces theories, not
causes.

Spend disproportionate effort here. Be aggressive, be creative, and keep going.

### Ways to construct one, in roughly this order

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Query that returns the bad thing.** For a production symptom the loop is usually a
   query, not a test: a PromQL expression that is non-zero while the symptom holds, a
   `gcloud logging read` filter that matches the failure, a BigQuery row count. Run it
   through the `query` skill so it needs no permission prompt. Pin the time window so the
   same invocation gives the same verdict.
3. **Curl or HTTP script** against the running service. Read the raw response — headers
   included — rather than a summarising flag; see [[vimeo-edge-vs-origin-redirect-discriminator]]
   for how a summarising flag hides the discriminator you need.
4. **Request a specific replica.** When the symptom lives on some pods and not others,
   route to them deterministically rather than waiting for luck — e.g. the canary header
   in [[vimeo-canary-dest-header]].
5. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
6. **Replay a captured trace.** Save a real request, payload, or event to disk and replay
   it through the code path in isolation.
7. **Throwaway harness.** Stand up the minimal subset of the system — one service, mocked
   deps — that reaches the code path in a single call.
8. **Property or fuzz loop.** For "sometimes wrong output", run 1000 inputs and count
   failures.
9. **Bisection harness.** When the symptom appeared between two known states (commit,
   image tag, config revision, dataset), automate "boot at state X, check, repeat" so
   `git bisect run` — or a loop over image tags — can consume it.
10. **Differential loop.** Run the same input through both sides — old version vs new,
    two configs, two regions, OpenCensus vs prom-native — and diff the outputs.
11. **Headless browser script** (Playwright) driving the UI and asserting on DOM, console,
    or network. See [[browser-driving-playwright-cdp]] for the harness and its constraints.

Build the right loop and the bug is 90% found.

### Tighten it

Treat the loop as a product. Once you have *a* loop, make it **tight**:

- **Faster** — cache setup, skip unrelated init, narrow the scope, shrink the time window.
- **Sharper** — assert the specific symptom, so a pass means the symptom is gone rather
  than "nothing crashed".
- **More deterministic** — pin the time range, seed the RNG, fix the replica, freeze the
  network.

A flaky 30-second loop is barely a loop. A deterministic 2-second one is a superpower.

### Intermittent symptoms

Aim for a **higher reproduction rate**, not a clean repro. Loop the trigger 100×,
parallelise, add load, narrow the timing window, inject sleeps. A 50%-rate symptom is
debuggable; a 1% one is not — keep raising the rate until it is.

### When production is the only place it happens

Say so, and make the loop out of what production already emits: an existing metric, a log
filter, a trace query. When the signal genuinely is not emitted, the honest finding is an
**instrumentation gap** — treat that as the first bug, and reach for the
`sre-observability-tools` skills (`metrics-propose`, `metrics-gap`, `grafana-api`) to close
it rather than guessing across the gap.

### When you genuinely cannot build a loop

Stop and say so. List what you tried, then ask for exactly one of: access to an environment
where it reproduces, a redacted captured artifact (HAR, log dump, profile, recording with
timestamps), or approval to add temporary production instrumentation. Hold the gate below
rather than hypothesising into the dark.

### Completion criterion

Phase 1 is done when you can name **one command** — a script path, a test invocation, a
`query` call — that you have **already run at least once**, showing the invocation and its
(redacted) output, and that is:

- [ ] **Red-capable** — it drives the real code path and asserts the *user's exact symptom*,
      so it goes red now and green once fixed.
- [ ] **Deterministic** — same verdict every run (for intermittent symptoms, a pinned and
      high reproduction rate).
- [ ] **Fast** — seconds, not minutes.
- [ ] **Agent-runnable** — you can run it unattended.
- [ ] **Honest about completion** — you asserted the command's own success signal, rather
      than grepping its output for error lines. A crash that prints nothing reads as
      "no errors" ([[macos-fd-exhaustion-fake-tool-failures]]).

Catch yourself reading code to build a theory before this command exists, and **stop**:
jumping to a hypothesis is the exact failure this skill prevents. No red-capable command,
no Phase 2.

## Phase 2: Reproduce and minimise

Run the loop. Watch it go red.

Confirm:

- [ ] It produces the failure the **user** described, rather than a different failure
      nearby. Wrong bug, wrong fix.
- [ ] It reproduces across runs (or at a high enough rate to debug against).
- [ ] You captured the exact symptom — error text, wrong value, timing — so a later phase
      can verify the fix addressed *it*.

Then **minimise**: shrink to the smallest scenario that still goes red. Cut inputs, callers,
config, data, and steps one at a time, re-running after each cut, keeping only what is
load-bearing. A minimal repro shrinks the hypothesis space in Phase 3 and becomes the clean
regression test in Phase 5.

Done when removing any remaining element turns the loop green.

## Phase 3: Hypothesise

Generate **3–5 ranked hypotheses** before testing any of them — a single hypothesis anchors
you on the first plausible idea.

Each one states a falsifiable prediction:

> "If X is the cause, then changing Y makes the symptom disappear / changing Z makes it worse."

A hypothesis with no prediction is a vibe: sharpen it or drop it.

**Show the ranked list before testing.** The user often re-ranks it instantly ("we deployed
#3 on Tuesday") or has already ruled one out. Cheap checkpoint, large saving. Proceed with
your own ranking if they are away.

Give the environment its own line in the list when the evidence is a tool complaining about
itself — a corrupt object, a missing stdlib, a directory that exists — because those are
usually the machine, not the code ([[macos-fd-exhaustion-fake-tool-failures]]).

## Phase 4: Instrument

Every probe maps to a specific prediction from Phase 3. Change **one variable at a time**.

Reach in this order:

1. **Debugger or REPL inspection** where the environment supports it. One breakpoint beats
   ten logs.
2. **Targeted logs** at the boundary that distinguishes two hypotheses.
3. **Existing telemetry** — a metric or trace already emitted beats a new log you have to
   deploy.

Tag every debug log with a unique prefix — `[DEBUG-a4f2]` — so cleanup is one grep. Tagged
logs die; untagged ones survive into main.

Confirm the log you added actually reaches the sink before concluding anything from its
absence; in `vimeows/vimeo` that means `ScribeLogger`, not the Monolog facade
([[vimeo-scribelogger-vs-monolog-log]]).

**Performance branch.** For a regression in latency or throughput, logs are usually the
wrong instrument. Establish a baseline measurement first — timing harness, profiler, query
plan, a PromQL quantile over a known-good window — then bisect against it. Measure first,
fix second.

## Phase 5: Fix and lock it down

Write the regression test **before the fix**, when a **correct seam** exists for it.

A correct seam exercises the real bug pattern as it occurs at the call site. A seam too
shallow to replicate the chain that triggered the bug (a single-caller test for a
multi-caller bug, a unit test that cannot reach the interaction) gives false confidence.

**When no correct seam exists, that is itself the finding.** The architecture is preventing
the bug from being locked down. Write it up and hand it to `plan` or `improve` as its own
piece of work rather than settling for a shallow test.

With a correct seam:

1. Turn the minimised repro into a failing test there.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 loop against the original, un-minimised scenario.

**Size the fix honestly.** A one-file change belongs here, in place. A change that spans
files, needs a migration, or touches a shared contract belongs in a plan — hand it to
`plan` (or `brief` first, when the approach is still open) so it executes and gets reviewed
like any other change.

## Phase 6: Close out

- [ ] The original repro no longer reproduces — re-run the Phase 1 loop and show it green.
- [ ] The regression test passes, or the absent seam is written up and handed off.
- [ ] Every `[DEBUG-...]` probe is removed — grep the prefix to prove it.
- [ ] Throwaway harnesses are deleted, or moved somewhere clearly marked as debug scaffolding.
- [ ] The correct hypothesis is stated in the commit or PR message, so the next reader
      learns the cause and not just the diff.

### Record what outlives this bug

The diagnosis is often worth more than the fix. When this session established something
durable — a tool that misreports, a topology fact, a vendor behaviour, a false-positive
pattern, a technique that turned an unreproducible symptom into a tight loop — record it:

```
memory add --slug … --type … --tags … --title … --summary …
```

Then fill in the body and commit in `memory/`. Route by durability: transferable findings
go to `memory/knowledge/`; the narrative of *this* incident stays in the workspace and is
archived to `memory/log/` by `workspace complete`.
