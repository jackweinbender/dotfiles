# AGENTS.md

This is an independent workspace under `~/Code/workspaces/`. It is self-contained: this file carries everything an agent needs to work here, with no dependence on parent config being loaded.

## Working here

- **Edit in worktrees.** All edits happen inside `.worktrees/<org>/<repo>-<branchname>/`. Never edit the clones under `~/Code/github.com/`.
- **Keep `WORKSPACE.md` current.** It is this workspace's running log — append decisions, dead ends, and links as work progresses. On completion it is distilled and archived to `~/Code/memory/log/`.
- **Lifecycle** is managed by the `workspace` CLI on `PATH` (create / open / status / complete / destroy). Don't reinvent it in ad-hoc shell.
- **Push discipline.** Don't push to, or change the state of, PRs that are marked done/ready-for-human-review without an explicit go-ahead. Prepare the change locally, ask, then execute.
- **Commit types.** Infrastructure-only changes (node pool migrations, version bumps, in-place upgrades, IAM cleanup) are `chore(<scope>): ...`, not `feat` — reserve `feat` for net-new modules, services, or capability surface.

## Memory

Durable, reusable knowledge — facts, procedures, conventions, patterns — lives in the shared memory store at `~/Code/memory/knowledge/` (git-tracked markdown, shared by all agents and tools).

- **Recall.** Read `~/Code/memory/knowledge/INDEX.md`, then the matching note(s) — before re-deriving something that smells already-solved. Full-text: `rg <term> ~/Code/memory/knowledge/`.
- **Record.** Learned something durable beyond this task? `memory add --slug … --type … --tags … --title … --summary …` (type ∈ `reference|procedure|convention|pattern|identity`), fill in the body, commit in `memory/`.
- **Routing.** The store is knowledge only. Task-scoped notes go in `WORKSPACE.md`; behavioral rules belong in `AGENTS.md` files; don't record durable knowledge in tool-private memory features.
