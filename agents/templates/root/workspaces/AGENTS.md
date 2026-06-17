# Workspaces

Conventions for work happening inside any workspace under `~/Code/workspaces/<name>/`.

## Edit in worktrees

All edits happen inside `.worktrees/<org>/<repo>-<branchslug>/` (the branch name with `/` replaced by `-`, so multiple branches of one repo can coexist and a slashed branch like `feat/x` doesn't nest a subdirectory). Never edit the clone under `~/Code/github.com/<org>/<repo>/`.

## Keep WORKSPACE.md current

`WORKSPACE.md` is the workspace's running log. Append notes as work progresses — decisions, dead ends, links. On completion it's distilled and archived to `~/Code/memory/log/`.

## TODOs (optional)

A workspace may optionally have its own `TODOS.md` for followups scoped to this work — same three sections as the global file (`END OF DAY`, `Active followups`, `TODO`). It is **not** in the template; create one ad-hoc when needed. Cross-cutting items go in `~/Code/TODOS.md` instead. On `workspace complete`, if a `TODOS.md` exists with open items, they're rolled up or explicitly discarded before tear-down — they don't survive the workspace.

## Lifecycle

Use the `workspace` skill / `workspace` CLI (on `PATH`) for create / open / status / complete / destroy. Don't reinvent these in ad-hoc shell.

## Memory

Durable, reusable knowledge lives in the shared memory store at `~/Code/memory/knowledge/` — scan its `INDEX.md` to recall, or `memory add` to record (see the `## Memory` contract in each workspace's own `AGENTS.md`, seeded from the template). The store is knowledge only: task-scoped notes go in `WORKSPACE.md`, not the store.
