# AGENTS.md

This file provides guidance for humans and AI agents working in `~/Code`.

## This directory is an orchestration space, not a project

`~/Code` is a parent folder containing several unrelated trees. It is not a monorepo. It exists to launch sessions that do their real work inside subtrees (repos or workspaces).

## How `~/Code` is materialized

The `agents` dotfiles topic (`~/.dotfiles/agents/`) materializes this config via `agents/bootstrap.zsh`, two ways:

- **Compiled (copied):** this file, `CLAUDE.md`, `.claude/settings.json`, `workspaces/{AGENTS,CLAUDE}.md` — from `templates/root/`. These are build artifacts — **edit the source and recompile; don't hand-edit the `~/Code` copies.**
- **Symlinked (live):** `.claude/skills/*` → the topic's `skills/`. Edit a `SKILL.md` and it's live immediately (no recompile); it's still git-tracked there, so still change-controlled.

Data is never touched: `memory/`, `github.com/`, and live `workspaces/<name>/` are yours. The CLIs (`memory`, `workspace`) run from `skills/bin/` on `PATH`.

## Directory layout

- `github.com/` — contains all of the extant cloned git repos. Repos follow their exact path from `github.com` to `<org>/<repo>`. So, the `acme/widgets` repo represents a repo cloned from `git@github.com:acme/widgets.git`.
- `memory/` — the shared memory store: `knowledge/` (recall notes) + `log/` (episodic archives). Git-tracked markdown, not code; edits here are prose. See `## Memory` below.
- `workspaces/` — each subdirectory is a workspace with its own `AGENTS.md` and `.worktrees/`.

## CLAUDE.md vs AGENTS.md

`AGENTS.md` is the source of truth for guidance to humans and AI agents. `CLAUDE.md` files should **only** exist to:

1. Configure Claude-specific features (e.g. settings, behaviors that only apply to Claude Code).
2. Import the sibling `AGENTS.md` via `@AGENTS.md`.

All business logic, conventions, and project guidance belong in `AGENTS.md`. Never duplicate guidance into `CLAUDE.md` — import it.

### How the chain loads

Claude Code automatically loads every `CLAUDE.md` from the session's cwd up to `~`. Each `CLAUDE.md` pulls in its sibling `AGENTS.md`. **Do not** add `@../AGENTS.md` imports in `AGENTS.md` files to "build a chain" — the parent layers are already loaded via the parent `CLAUDE.md`'s auto-walk, and explicit upward imports are redundant noise.

### Workspaces are hermetic (deliberately exempt from the walk)

A workspace is its *own* context and should be unaware it lives inside an orchestration folder. So each workspace's `.claude/settings.json` sets `claudeMdExcludes` to drop this orchestration config — `**/Code/CLAUDE.md`, `**/Code/AGENTS.md`, and the `**/Code/workspaces/` pair — from its walk. A session in a workspace therefore loads **only** that workspace's self-contained `AGENTS.md`, not this file.

Consequences, so neither human nor agent "fixes" them later:

- The overlap between this file's conventions and a workspace's `AGENTS.md` is **not** redundancy to dedupe. The workspace copy is self-contained *on purpose*; the exclude is what stops the parent from bleeding in. Removing the excludes or thinning the workspace `AGENTS.md` breaks the isolation.
- This is `CLAUDE.md`-memory only. **Skills are unaffected** — they discover via their own walk-up to `~/Code/.claude/skills/`, so a workspace session still has `plan`, `execute`, `workspace`, `memory`, `tdd`, etc.
- The exclude lives in the workspace template (`templates/workspace/.claude/settings.json`), so every new workspace is hermetic by default. Settings don't inherit, so it must be present in each workspace's own `.claude/`.

## Editing code

Both humans and AI agents may edit code under `~/Code`. Follow these conventions.

### Prefer editing in a workspace

Edits should typically happen in a dedicated workspace. Short-lived workspaces are worthwhile for all but the most trivial tasks.

Only edit a repo in place when that repo is the session's `cwd`.

Exception: **editing `~/.dotfiles`** (any dotfiles topic — shell config, the `agents` topic, skills, etc.) happens directly in `~/.dotfiles`, no workspace or worktree. Commit there as usual. See `## Skills` for the skills case.

### Use tmux for managing Claude sessions

Use `tmux` windows and panes to ensure the correct context and settings are loaded for work.

Prefer dedicated `tmux` windows for workspace sessions:

```bash
# create a new workspace window named `<name>` and start claude
tmux new-window -n <name> -c ~/Code/workspaces/<name> "claude"
# switch to an existing window named `<name>`
tmux select-window -t <name>
# or combine for 'switch-or-create' semantics
tmux select-window -t <name> 2>/dev/null || tmux new-window -n <name> -c ~/Code/workspaces/<name> "claude"
```

Opening a specific repo in-place can open in a pane:

```bash
# horizontal split
tmux split-window -h -c ~/Code/github.com/<org>/<repo>
# vertical split
tmux split-window -v -c ~/Code/github.com/<org>/<repo>
```

## Cloning repos

- Always clone over SSH (`git@github.com:<org>/<repo>.git`), never HTTPS.
- Ask before cloning a new repo.
- Clone into `github.com/<org>/<repo>/`. If the `<org>/` directory doesn't exist yet, create it as part of the clone.

## Workspaces

Workspaces are isolated places to do work, under `~/Code/workspaces/<name>/`. They have their own `AGENTS.md` chain — see `~/Code/workspaces/AGENTS.md` for conventions that apply inside a workspace.

When asked to "cut a workspace" to execute work, hand the execution off to an agent session *inside* that workspace (subagent scoped to it, or a fresh session in its tmux window) — don't run the edits inline in the orchestration session. The point of the workspace is isolation.

## Memory

The shared memory store lives at `~/Code/memory/` — git-tracked markdown, editable by any tool (Obsidian is just one editor). Two halves:

- `knowledge/` — the recall corpus: durable facts, procedures, conventions, patterns (one per note, `[[wikilink]]`-graphed), indexed by `knowledge/INDEX.md`.
- `log/` — episodic archives of completed work (written by `workspace complete`, read as history).

The contract:

- **Recall.** Read `~/Code/memory/knowledge/INDEX.md` (one line per note), then the matching note(s) — before re-deriving something that smells already-solved. For full-text search, `rg <term> ~/Code/memory/knowledge/`. (The `memory` skill documents this.)
- **Record.** Learned something durable? `memory add --slug … --type … --tags … --title … --summary …` (type ∈ `reference|procedure|convention|pattern|identity`), then fill in the body and commit in `memory/`. It keeps `INDEX.md` in sync.
- **Routing.** The store is durable *knowledge*; recall targets `knowledge/`. Always-applied behavioral rules belong in the relevant `AGENTS.md`; task-scoped notes in `WORKSPACE.md`; completed-work narratives are episodic → `log/`.
- **No tool-private stores.** Don't record durable knowledge in tool-specific memory features (e.g. Claude Code auto-memory) — this store is the single source of truth.

## TODOs

`~/Code/TODOS.md` holds cross-cutting followups — Slack threads, errands, anything that came up while focused elsewhere and doesn't belong to a single workspace. Three sections:

- **END OF DAY** — close out before EOD.
- **Active followups** — after the current active work wraps.
- **TODO** — no specific due date.

A workspace may optionally add its own `TODOS.md` for workspace-scoped followups (see `~/Code/workspaces/AGENTS.md`).

## Scripts

The orchestration CLIs (`memory`, `workspace`) are on `PATH` — call them as bare commands. They live in the `agents` dotfiles topic's `skills/bin/` and run from there, not from `~/Code`.

## Skills

Skills live at `~/Code/.claude/skills/<name>/SKILL.md`, where Claude Code auto-loads them. Each is a **symlink** to `~/.dotfiles/agents/skills/<name>/` — edit a `SKILL.md` there and it's live immediately (no recompile; still git-tracked in the dotfiles, so still change-controlled). Their backing CLIs live in `agents/skills/bin/` on `PATH`.

The skills compose into an **opt-in idea→implementation pipeline** — `brainstorm → vet → brief → plan → execute` — whose two thinking stages (`brainstorm`, `vet`) run here in the main thread and hand off to a workspace via `brief`. Reach for them deliberately; work is not auto-routed. See `memory/knowledge/skill-pipeline.md` for the full flow, the optional skip-ahead moves, and the invariants.

**Develop skills directly in `~/.dotfiles/agents/skills/`** — like all `~/.dotfiles` edits (see "Prefer editing in a workspace" above), do *not* cut a workspace or worktree. The `~/Code/.claude/skills/*` symlinks point back to that tree, so in-place edits go live immediately and stay git-tracked there (that's the change-control boundary). Commit skill changes in the `~/.dotfiles` repo as usual.

Skills should broadly be structured following the format at https://pi.dev/docs/latest/skills. Accompanying scripts and CLIs should abide by the skill-composition note in the memory store (`memory/knowledge/claude-skill-composition.md`).
