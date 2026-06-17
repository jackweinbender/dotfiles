---
name: tdd
description: Drive a change test-first via red→green→refactor in vertical slices — one behavior, one test, one minimal implementation at a time. Tests verify behavior through public interfaces so they survive refactors. Use when hand-coding a logic-heavy change in-session, or as the discipline an executor follows at a plan's flagged TDD seam. For test-after auditing of a finished diff, that lives in `execute`'s review.
license: MIT
metadata:
  author: jack.weinbender
  adapted-from: mattpocock/skills (engineering/tdd)
  version: "1.0.0"
---

# tdd

Build a change test-first: one behavior at a time, **red → green → refactor**, with tests that describe *what* the system does through its public interface — not *how* it does it internally. Those tests survive refactors; tests coupled to implementation are a liability.

This is a discipline skill. Reach for it two ways:

- **In-session**, when you're hand-coding a logic-bearing change and want the rigor.
- **As an executor**, when a handoff plan's `## Test plan` marks a **TDD seam** — the plan already names the behaviors to test, so you run the loop without the interactive gate below.

For auditing tests *after* a diff exists, that's `execute`'s Standards review, not this skill.

## Phase 0 — Recall

Read `~/Code/memory/knowledge/testing-discipline.md` — the cross-repo definition of good vs. bad tests this skill enforces. Then `rg` the repo's existing tests for the framework, assertion style, and naming the new tests must match. Don't invent a test style the repo doesn't use.

## Anti-pattern: horizontal slices

**Do NOT write all the tests first and then all the implementation.** Bulk-written tests test *imagined* behavior: you commit to a test shape before you understand the implementation, end up asserting structure rather than behavior, and the suite goes insensitive to the changes that matter. Go vertical — one test, one implementation, repeat — so each test responds to what the previous cycle taught you.

```
WRONG (horizontal):  RED: test1..test5   then   GREEN: impl1..impl5
RIGHT (vertical):    test1→impl1 → test2→impl2 → test3→impl3 → …
```

## Planning gate (in-session only)

Before writing code, pin down the seam — resolve from the codebase first, ask only what the code can't answer:

- What should the **public interface** look like (the surface the tests will drive)?
- **Which behaviors matter most?** You can't test everything — list the behaviors as specifications ("rejects an expired token"), prioritized, focused on critical paths and complex logic, not every edge case.

> **Executor note:** when a plan dispatched you to a TDD seam, this gate is already resolved — the plan's `## Test plan` carries the prioritized behavior list and the interface. Skip the questions; go straight to the loop below.

## The loop

**Tracer bullet first.** Write ONE test for the first behavior; watch it fail (RED); write the minimal code to pass (GREEN). This proves the path end-to-end.

**Then, per remaining behavior:**

```
RED:   write the next test → it fails
GREEN: minimal code to pass → it passes
```

Rules:

- One test at a time. Only enough code to pass the current test.
- Don't anticipate future tests; add no speculative features.
- Keep each test on observable behavior through the public interface.

## Refactor — only when green

After the tests pass, look for cleanups: extract duplication, deepen modules (move complexity behind a small interface), apply structure the new code revealed. Re-run the tests after each step. **Never refactor while red** — get to green first.

## Per-cycle checklist

- [ ] Test describes behavior, not implementation
- [ ] Test drives the public interface only (no private methods, no internal-collaborator mocks, no side-channel assertions)
- [ ] Test would survive an internal refactor that preserves behavior
- [ ] Code is the minimum for this test; nothing speculative added
