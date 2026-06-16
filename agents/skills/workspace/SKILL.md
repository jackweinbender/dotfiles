---
name: workspace
description: Operations on workspaces under ~/Code/workspaces/ — create, open, status, list, complete (distill WORKSPACE.md, archive to memory/log, tear down), and destroy (force-remove with no archive). Use when the user asks to scaffold, switch into, inspect, wrap up, or abandon a workspace.
---

# workspace

Workspaces are isolated working directories under `~/Code/workspaces/<name>/`, each with its own `AGENTS.md`, `WORKSPACE.md`, and `.worktrees/`. See `~/Code/AGENTS.md` for the broader convention.

**Worktree layout.** Git worktrees live at `~/Code/workspaces/<name>/.worktrees/<org>/<repo>-<branchname>/`. The branch name is the literal branch (not the string `"branch"`), so multiple branches of the same repo can coexist in one workspace. When adding a worktree, follow this convention — e.g. `acme/api-add-healthcheck/` for the `add-healthcheck` branch of `acme/api`.

All workspace lifecycle operations go through the `workspace` CLI (on your `PATH`). **Whenever a step can be done procedurally, prefer the CLI over ad-hoc shell.**

## When to use

Invoke when the user asks to:
- create a new workspace (e.g. "make a scratch workspace", "new workspace for X")
- open or switch into a workspace ("jump into X", "open the X window")
- inspect a workspace's state ("what's in X?", "is X clean?")
- complete a workspace ("close out X", "wrap up X")
- destroy a workspace ("nuke X", "trash X", "force-delete X" — for throwaways with no work worth archiving)
- list workspaces ("what workspaces do I have?")

Do **not** invoke for:
- edits inside an existing workspace — that's just regular file editing
- changes to the workspace template — edit it in `~/.dotfiles/agents/templates/workspace/`
- new git repos or worktrees inside a workspace

## CLI

```
workspace <command> [options]
```

The `workspace` CLI is on `PATH` and permitted via `Bash(workspace:*)` in `~/Code/.claude/settings.json`, so it runs without an approval prompt.

### Commands

#### `create --name <name> [--open]` (alias: `new`)

Copy the workspace template (`~/.dotfiles/agents/templates/workspace/`) to `~/Code/workspaces/<name>/`. With `--open`, also drop the user into a tmux window running Claude in the new workspace.

```bash
workspace create --name <name> --open
# or:
workspace new --name <name> --open
```

Fails if `<name>` already exists, the template is missing, or the name contains characters outside `[A-Za-z0-9._-]`.

#### `open --name <name>`

Switch to the workspace's tmux window if it exists; otherwise create one and start Claude in it. This replaces hand-written `tmux new-window` calls — use it instead.

```bash
workspace open --name <name>
```

#### `status --name <name>`

Print a structured view of the workspace: WORKSPACE.md state (`missing` / `empty` / `stub` / `populated`) and, for each worktree, branch, upstream, dirty/clean, ahead/behind, last commit. Use this **before** running `complete` to confirm everything's in order, instead of ad-hoc `git status` / `git log` calls.

```bash
workspace status --name <name>
```

#### `list`

Print all workspaces with worktree counts, WORKSPACE.md state, and a `READY` column indicating whether `complete` would succeed.

```bash
workspace list
```

#### `complete --name <name> [--dry-run]`

Tear down a finished workspace: remove its worktrees, archive its `WORKSPACE.md` into the memory log, delete the workspace directory, and close its tmux window.

**This command is destructive.** Use `--dry-run` to preview the plan without executing.

The CLI refuses to run if:
- The workspace doesn't exist.
- `WORKSPACE.md` is missing.
- `WORKSPACE.md`'s `## Summary` section is empty or still the template stub.
- Any worktree has uncommitted changes.
- The destination log file (`~/Code/memory/log/YYYY-MM-DD-<name>.md`) already exists.

On success it runs `git worktree remove` for each worktree, moves `WORKSPACE.md` to `~/Code/memory/log/`, `rm -rf`s the workspace directory, and `tmux kill-window -t <name>`. It then prints the list of preserved branches (worktree removal doesn't delete branches; they survive on origin if pushed).

Unpushed commits are **not** checked — branches survive worktree removal regardless.

#### `destroy --name <name> [--dry-run]`

Force-remove a workspace with **no archive and no AI flow**: force-removes worktrees (discarding any uncommitted changes), `rm -rf`s the workspace directory, and closes the tmux window. Branches are preserved (worktree removal doesn't delete branch refs), but uncommitted changes in dirty worktrees are gone.

Use this for throwaway workspaces where there's nothing worth distilling — debug spikes, experiments, mistakes. For workspaces with real work, use `complete` instead.

The CLI only refuses if the workspace doesn't exist. It does **not** check WORKSPACE.md state, Summary content, or worktree dirtiness.

```bash
workspace destroy --name <name>
```

## The `complete` flow

The CLI handles all mechanical work. Two steps require AI judgment and must be done **before** running `complete`:

### 1. Run `workspace status --name <name>` to confirm preflight state

Use the CLI output, not ad-hoc git commands.

### 2. Distill `WORKSPACE.md`'s `## Summary` section

Read `~/Code/workspaces/<name>/WORKSPACE.md` and rewrite the `## Summary` section so a reader who never saw this workspace can understand what was done and why: goal, key decisions, what shipped, anything notable left undone. The `## Log` section stays as-is. If the running log is empty, reconstruct from commit messages — and say so in the Summary (`_(reconstructed from commits)_` or similar).

The CLI will refuse to complete if Summary is empty or still the stub, so this step is enforced.

### 3. Handle workspace TODOs (if a `TODOS.md` exists)

Workspace `TODOS.md` is optional — it's not in the template and only exists if created ad-hoc. If `~/Code/workspaces/<name>/TODOS.md` is present with open items in any of `END OF DAY`, `Active followups`, or `TODO`, surface them to the user and ask what to do. The likely default is to roll them up into the matching sections of `~/Code/TODOS.md`, but the user may say to drop specific items or skip the rollup entirely. Resolve every open item before running `complete` — the workspace `TODOS.md` is deleted with the workspace, so anything not migrated is lost.

### 4. Propose durable-knowledge candidates and record them

Re-read the distilled WORKSPACE.md and identify anything that should outlive the workspace — procedures, design decisions with lasting force, gotchas, conventions, references. **Propose** each to the user as a candidate memory note (a `--slug`, a `--type`, and a one-line `--summary`). **Wait for explicit approval.** If there's nothing durable, say so and skip.

On approval, record each through the `memory` skill — `memory add --slug … --type … --tags … --title … --summary …` — then fill in the body from the WORKSPACE.md detail and commit in `memory/`. This closes the episodic→knowledge loop: the archived log captures *what happened*; the memory note captures the *durable lesson*. Let `memory add` own the frontmatter and `INDEX.md` — don't hand-write into the store. (The completed-work log itself is moved to `~/Code/memory/log/` by the CLI in the next step — don't write there yourself.)

### 5. Run `workspace complete --name <name>` (or `--dry-run` first)

```bash
workspace complete --name <name>
```

Report the preserved-branches output back to the user.

## Adding new commands

New subcommands are added to the `workspace` CLI (Ruby, stdlib only — no gems). Document each under `### Commands` above and reflect any new flow in the front-matter `description` so the skill stays discoverable.

The permission `Bash(workspace:*)` covers the CLI, so new subcommands don't need additional permission entries.

**Rule of thumb when extending:** anything that's deterministic and procedural belongs in the CLI. Reserve SKILL.md prose for steps that genuinely need AI judgment (summarization, semantic filtering, asking the user).
