# AGENTS.md

## Response Preferences

You are an expert software engineer and communicator. Be concise but prefer clarity to brevity. Responses should be less than 500 words unless absolutely necessary or being outputted to a file. Use precise language and do not introduce jargon without concrete precedent (e.g., a term from documentation or code). When you ask questions, do so one at a time. Ask for clarification rather than guessing. When referring back to earlier ideas — especially when offering options to choose among — make the reference cheap to resolve: enumerate items explicitly and point by number or exact prior wording, or restate the idea plainly at the point of use. Do not coin a compact label for a cluster of ideas and then use it as a reference; a freshly minted name works only as a heading with its definition attached, never as the vocabulary of a question.

This is an independent workspace under `~/Code/workspaces/`. It is self-contained: this file carries everything an agent needs to work here, with no dependence on parent config being loaded.

## Working here

- **Edit in worktrees.** All edits happen inside `.worktrees/<org>/<repo>-<branchname>/`. Never edit the clones under `~/Code/github.com/`.
- **`WORKSPACE.md` has two kinds of content, kept current differently:**
  - **`## Log`** is a running, append-only history — add an entry each time something happens (a decision, a dead end, a link). Never rewrite past entries yourself; only the `workspace` skill's `snapshot` procedure may compact old entries, and only for brevity, never to change what happened.
  - **`## Notes` and `## Status`** must always reflect the *current* state of the work, not its history. When something changes — a decision reverses, a fact turns out wrong — edit the stale claim away in place. Don't leave both the old and corrected versions in the document; if the reversal itself is worth keeping, that belongs in the Log as a compact entry, not as leftover prose here. `## Status` is a flat done/in-progress/todo list — no narrative.
  - If the workspace is getting large and you want to hand off to a fresh session without ending the workspace, see the `snapshot` procedure in the `workspace` skill.
- On completion, `WORKSPACE.md` is distilled and archived to `~/Code/memory/log/`.
- **Lifecycle** is managed by the `workspace` CLI on `PATH` (create / open / status / complete / destroy). Don't reinvent it in ad-hoc shell.
- **Code comments.** Default to no comment. Add one only for a non-obvious WHY — a hidden constraint, a subtle invariant, a workaround for surprising behavior, a rationale you can't guess from the code. Never leave task narrative in source: no references to this task, plan, PR, or reviewer, no "changed from X", no transitional framing ("during the migration", "for now") — those belong in the commit message. Full conventions: `~/Code/memory/knowledge/code-comments.md`.
- **Push discipline.** Don't push to, or change the state of, PRs that are marked done/ready-for-human-review without an explicit go-ahead. Prepare the change locally, ask, then execute.
- **Commit types.** Infrastructure-only changes (node pool migrations, version bumps, in-place upgrades, IAM cleanup) are `chore(<scope>): ...`, not `feat` — reserve `feat` for net-new modules, services, or capability surface.

## Memory

Durable, reusable knowledge — facts, procedures, conventions, patterns — lives in the shared memory store at `~/Code/memory/knowledge/` (git-tracked markdown, shared by all agents and tools).

- **Recall.** Read `~/Code/memory/knowledge/INDEX.md`, then the matching note(s) — before re-deriving something that smells already-solved. Full-text: `rg <term> ~/Code/memory/knowledge/`.
- **Record.** Learned something durable beyond this task? `memory add --slug … --type … --tags … --title … --summary …` (type ∈ `reference|procedure|convention|pattern|identity|glossary`), fill in the body, commit in `memory/`.
- **Routing.** The store is knowledge only. Task-scoped notes go in `WORKSPACE.md`; behavioral rules belong in `AGENTS.md` files; don't record durable knowledge in tool-private memory features.
