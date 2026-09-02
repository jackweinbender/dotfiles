---
name: workspace
description: Operations on workspaces under ~/Code/workspaces/ — create, open, status, list, snapshot (mid-flight WORKSPACE.md compaction for a clean handoff, no teardown), complete (distill WORKSPACE.md, retro the environment for defects worth fixing, archive to memory/log, tear down), and destroy (force-remove with no archive). Use when the user asks to scaffold, switch into, inspect, compact, wrap up, or abandon a workspace.
---

# workspace

Workspaces are isolated working directories under `~/Code/workspaces/<name>/`, each with its own `AGENTS.md`, `WORKSPACE.md`, and `.worktrees/`. See `~/Code/AGENTS.md` for the broader convention.

**Worktree layout.** Git worktrees live at `~/Code/workspaces/<name>/.worktrees/<org>/<repo>-<branchslug>/`. The `<branchslug>` is the branch name with any `/` replaced by `-` (the branch keeps its real name — only the directory is flattened), so multiple branches of the same repo can coexist in one workspace and a slashed branch like `feat/x` doesn't nest a subdirectory and break worktree enumeration. When adding a worktree, follow this convention — e.g. `acme/api-add-healthcheck/` for the `add-healthcheck` branch of `acme/api`, or `acme/api-feat-x/` for `feat/x`.

All workspace lifecycle operations go through the `workspace` CLI (on your `PATH`). **Whenever a step can be done procedurally, prefer the CLI over ad-hoc shell.**

## When to use

Invoke when the user asks to:
- create a new workspace (e.g. "make a scratch workspace", "new workspace for X")
- open or switch into a workspace ("jump into X", "open the X window")
- inspect a workspace's state ("what's in X?", "is X clean?")
- complete a workspace ("close out X", "wrap up X")
- snapshot a workspace mid-flight ("compact this workspace", "clean this up so I can hand it off", "snapshot my work")
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

#### `create --name <name> [--open [--editor <cmd>] [--prompt <text>]]` (alias: `new`)

Copy the workspace template (`~/.dotfiles/agents/templates/workspace/`) to `~/Code/workspaces/<name>/`. With `--open`, also drop the user into a tmux window running the editor in the new workspace. `--editor` is optional — when omitted it defaults to the agent tool you launched from (see `open` below for how that's inferred). `--prompt` (optional) seeds the launched tool with an initial input — see `open` below.

```bash
# launches whichever agent you're running in (opencode or claude):
workspace create --name <name> --open
# force a specific editor:
workspace new --name <name> --open --editor claude
# seeded launch (e.g. from the `brief` skill):
workspace create --name <name> --open \
  --prompt "Read ./BRIEF.md and follow it; invoke the plan skill to produce the plan set."
```

Fails if `<name>` already exists, the template is missing, or the name contains characters outside `[A-Za-z0-9._-]`.

#### `open --name <name> [--editor <cmd>] [--prompt <text>]`

Switch to the workspace's tmux window if it exists; otherwise create one and start the editor in it. `--editor` is optional: when omitted, the CLI infers the editor from the agent tool you launched from — it reads the calling process's environment (`OPENCODE` → `opencode`; `CLAUDECODE`/`CLAUDE_CODE_SSE_PORT` → `claude`), so a new window inherits your current agent. Pass `--editor` explicitly to override (e.g. `claude`, `opencode`, `vim`). If neither an explicit editor nor a known agent is detected, the command errors. This replaces hand-written `tmux new-window` calls — use it instead.

A **freshly opened** window is split into two panes: the editor on top, and a plain shell (your default shell) rooted in the workspace cwd as a ~30%-height bottom pane, with focus left on the editor. An **existing** window is just re-selected — no re-split.

`--prompt` (optional) seeds the launched tool with an initial input, using the tool-specific form: a bare positional for `claude` (`claude "Read ./BRIEF.md …"`) and the `--prompt` flag for `opencode` (`opencode --prompt "…"`); unknown tools get the positional form. It **only applies to a freshly opened window**; if the window already exists, `open` just selects it (the live session can't be re-seeded). The `brief` skill uses this to launch a planner straight onto the brief.

```bash
workspace open --name <name>                        # inherits your current agent
workspace open --name <name> --editor opencode      # force a specific editor
workspace open --name <name> --prompt "Read ./BRIEF.md and follow it."
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

The CLI handles all mechanical work. Steps 2–5 require AI judgment and must be done **before** running `complete`.

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

### 5. Retro — what the environment cost this run

Step 4 harvests durable *knowledge*. This step harvests **environment defects**:
the things about the agent's surroundings that made this run slower, wronger, or
more expensive than it needed to be. The output is proposed edits to skills,
`AGENTS.md`, or the repo's checks — never memory notes.

Re-read the `## Log` for friction, and look specifically for:

- **Navigation** — how long did it take to find the right file? Was there a
  hidden dependency between files nothing pointed at? *Fires when the log shows
  a long hunt for one piece of information.*
- **Automated checks** — could a linter, type check, test, or schema validation
  have caught a mistake that a human or a review round caught instead? *Fires on
  any mistake a machine could have named.*
- **Reviewer rules** — should `execute`'s Standards axis carry a new rule, or a
  clarified one? *Fires when review missed something, or flagged something it
  should not have.*
- **Steering files** — is an instruction in an `AGENTS.md` doing work that a
  coding standard or an automated check should do instead? *Fires when an
  `AGENTS.md` is growing.*
- **Tool economy** — which tool calls were expensive for what they returned? Is
  a CLI or MCP server token-inefficient in a way a wrapper could fix? *Fires
  after an expensive call.*
- **No-ops** — an instruction in a skill or steering file that the model already
  obeys by default. Grade it against the test in
  `~/Code/memory/knowledge/writing-for-agents.md`. *Fires when a steering file
  is large.*
- **Information access** — was a crucial fact simply unreachable? A log stream
  not teed, a dashboard without read access, an env var never surfaced. *Fires
  when the agent had to guess at something observable.*

Present the candidates ordered by severity, each naming the **fix and its home**
— a skill edit, an `AGENTS.md` line, a new check, a wrapper in `skills/bin/`, or
an access request. **Wait for approval before editing anything.** Nothing found
is a normal and good outcome; say so and move on.

Route by where the cost lands. Implementation carries the most **context
pressure** — it explores, writes, and debugs — while review receives a diff and
carries the least. So a new *standard* belongs on the review axis, not in the
implementer's prompt; only a rule the implementer must hold *while writing*
earns a place in `AGENTS.md`.

### 6. Run `workspace complete --name <name>` (or `--dry-run` first)

```bash
workspace complete --name <name>
```

Report the preserved-branches output back to the user.

## Snapshotting a workspace (mid-flight hygiene)

`snapshot` is **not a CLI command** — it's a procedure you perform directly on `WORKSPACE.md` with Read/Edit, the same way `complete`'s Summary-distillation step is AI judgment rather than code. Once backups and previews are off the table (see below), there is no deterministic work left to delegate to the CLI, so this stays entirely in this document.

Use it when a workspace's `WORKSPACE.md` has grown cluttered with churn — reversed decisions, corrected facts, dead ends — and you want the *next* session (yours after a restart, or a different agent) to pick up from a small, current document instead of re-deriving state from a long history. Unlike `complete`, `snapshot` doesn't end the workspace, touch worktrees, or open/close any session — it only rewrites `WORKSPACE.md`.

**This operation is irreversible.** There is no backup and no dry-run — read carefully before you save. Both were considered and deliberately rejected: workspace directories aren't git-tracked, and the goal was to keep this simple rather than build undo machinery.

### Precondition

`workspace status --name <name>` should report `WORKSPACE.md` as `populated`. If it's `empty` or `stub`, there's nothing to snapshot.

### 1. Compact `## Log`

`## Log` carries a marker comment (seeded by the template: `<!-- snapshot marker: entries above this line are archived (compacted); entries below are since the last snapshot -->`). Entries **below** the marker are since the last snapshot — full, verbatim, as written during work. Entries **above** it are the archive — already one terse line each, in original order.

- Rewrite every entry currently below the marker into a single terse line each (the fingerprint of what happened, not the full reasoning), preserving relative order.
- Append those lines, in order, to the end of the archive block, above the marker.
- Move the marker to the end of `## Log` — nothing is "since the last snapshot" again until new entries land after it.
- Leave lines already above the marker untouched. This is a one-time demotion per entry (full → terse), not progressive re-compaction on every run — that's enough to make older entries read shorter than newer ones without tracking how many times each line has been compacted.

### 2. Refresh `## Notes` and `## Status`

These sections should always read as the current state of understanding, not a history of how you got there.

- Read the whole section. Delete anything superseded, reversed, or corrected — don't mark it "superseded" and leave it sitting next to the correction; only the true version should remain.
- If a reversal is worth remembering for provenance (e.g. "tried X, reverted because Y"), that belongs as a compacted `## Log` line, not as leftover prose here.
- Normalize `## Status` to a flat done/in-progress/todo list — no narrative.

### 3. Stop

Don't open a new session, touch tmux, or touch worktrees. Starting a fresh session on the compacted workspace is a separate, already-existing step: `workspace open --name <name>`.

### When your own context is the problem

Default to doing this yourself, inline, in the session that just did the work — you have the freshest read on what's actually superseded, and a fresh subagent would only have to re-derive that same judgment cold from the same messy document. But if your own context is already too degraded to trust that judgment — the reason you're bailing in the first place — dispatch a fresh subagent to read `WORKSPACE.md` cold and perform the same two steps instead.

## Adding new commands

New subcommands are added to the `workspace` CLI (Ruby, stdlib only — no gems). Document each under `### Commands` above and reflect any new flow in the front-matter `description` so the skill stays discoverable.

The permission `Bash(workspace:*)` covers the CLI, so new subcommands don't need additional permission entries.

**Rule of thumb when extending:** anything that's deterministic and procedural belongs in the CLI. Reserve SKILL.md prose for steps that genuinely need AI judgment (summarization, semantic filtering, asking the user).
