# agents

The `~/Code` agent-orchestration system, managed as a dotfiles topic.

`~/Code` is a workspace launcher: git clones under `github.com/`, scratch `workspaces/`, a private `memory/` store. Two concerns make it work, with two materialization modes:

```
agents/
├── bootstrap.zsh     sets up ~/Code: compiles templates/root, symlinks skills
├── README.md
├── skills/           live capabilities (symlinked docs + PATH bin)
│   ├── bin/          → PATH ($DOTFILES/agents/skills/bin): memory, workspace
│   ├── memory/       SKILL.md → symlinked to ~/Code/.claude/skills/memory/
│   └── workspace/    SKILL.md → symlinked to ~/Code/.claude/skills/workspace/
└── templates/        pure-copy resources
    ├── root/         → compiled into ~/Code (AGENTS.md, CLAUDE.md, .claude/settings.json, workspaces/)
    └── workspace/    → stamped per `workspace create`
```

- **`skills/` — live.** A capability is a recipe (`SKILL.md`) + its primitive (a CLI in `bin/`). `bootstrap.zsh` **symlinks** each `skills/<name>/` into `~/Code/.claude/skills/`, and `skills/bin/` is on `PATH`. Edit a skill and it's live immediately — change control comes from git-tracking it here. Per-skill `recipes/` scripts can sit alongside a `SKILL.md` later.
- **`templates/` — copied.** `root/` is **compiled** into `~/Code` by `bootstrap.zsh` (build artifacts — edit the source, recompile; don't edit the `~/Code` copies). `workspace/` is **stamped** into each new `~/Code/workspaces/<name>/` by `workspace create`, read straight from here.

**Setup:** chained from `osx/bootstrap.zsh`, or run `zsh ~/.dotfiles/agents/bootstrap.zsh`. Idempotent. After editing anything here, run `agents_init` (defined in `zsh/lib/_.zsh`) to recompile `~/Code` config and relink skills.

**Not managed here (private / separate):** the `~/Code/memory/` store (its own repo) and the `~/Code/github.com/` clones.
