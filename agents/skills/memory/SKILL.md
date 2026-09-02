---
name: memory
description: The shared, tool-agnostic memory store at ~/Code/memory/knowledge/ — durable markdown notes (facts, procedures, conventions, patterns, gotchas, per-repo glossaries). RECALL before re-deriving something already solved (read INDEX.md, then the matching note). RECORD durable knowledge with `memory add`. Use at the START of any task that smells already-handled, or when you learn something worth keeping.
---

# memory

The memory store is the shared knowledge base at `~/Code/memory/knowledge/` — plain, git-tracked markdown notes (one fact/procedure/convention per file) with YAML frontmatter (`type`, `tags`, `created`). Any tool can read and write it. It is **not** auto-loaded into context; you reach a note on demand. (Episodic archives of completed work live alongside in `~/Code/memory/log/` — history, not recall.)

## Recall — use your own tools, not a CLI

There is **deliberately no search command**. Recall is judgment, and you already have everything you need:

1. **Read `~/Code/memory/knowledge/INDEX.md`** — one curated line per note (title + hook). This is the map. Scan it first.
2. **Read** the note(s) whose line matches the task.
3. For ad-hoc / full-text search, **`rg <term> ~/Code/memory/knowledge/`** — then Read the hits and judge relevance yourself. Your semantic judgment beats any fixed scorer, which is why this isn't wrapped in a script.

Do this at the **start** of work, or whenever a question smells already-answered:
- "have we hit this before?" before debugging or re-deriving
- a known **convention** (code style, commit types, CI layout), **procedure** (deploying a service, rotating a credential), **fact/topology** (which datastore is canonical, the service dependency graph), or **gotcha** (a flaky test, a config that won't load locally)

## Record — `memory add`

When you learn something durable and reusable beyond the current task, record it. The `memory` CLI (on `PATH`) owns only the *deterministic* parts (schema-correct frontmatter, today's date, keeping `INDEX.md` in sync) — covered by `Bash(memory:*)`, so it runs without a prompt.

```bash
memory add \
  --slug ci-uses-shallow-clones \
  --type reference \
  --tags "ci, git" \
  --title "CI uses shallow clones" \
  --summary "the build runner fetches depth=1; deepen before any tag-describe step or it fails."
```

This writes `~/Code/memory/knowledge/<slug>.md` with correct frontmatter and registers its `INDEX.md` line. Then **fill in the body** (Edit/Write — that's the knowledge, your judgment) and **commit in `memory/`** (commits are by hand, so you control the message and grouping).

- `--type` ∈ `reference` (a fact / how-things-are) · `procedure` (a how-to) · `convention` (a normative standard) · `pattern` (general/transferable) · `identity` (a person) · `glossary` (see below). One fact per note; link related notes with `[[slug]]` wikilinks.
- Keep `--summary` to one recall-cue line — it becomes the `INDEX.md` hook.

**Do not** record here: episodic "what I did" narratives (→ `WORKSPACE.md`, then `memory/log/`), always-applied behavioral rules (→ the relevant `AGENTS.md`), or general knowledge the model already has. The store is for *local, durable, hard-won* knowledge.

## Glossary notes — the one exception to one-fact-per-note

A `glossary` note carries a **repo's or domain's ubiquitous language**: the terms
the code and the team actually use, each defined in a line or two. It is the one
type exempt from one-fact-per-note, because the value is in having the vocabulary
*as a set* — an agent that holds the shared language names things consistently,
reads the codebase faster, and stops spending twenty words on a concept the team
has one word for.

Slug them `<repo-or-domain>-glossary` (e.g. `vimeo-edge-glossary`) so the set is
greppable, and keep them to vocabulary:

- **In:** the term, what it means here, and the distinction it draws against the
  term it is most often confused with. Point at the note or the `file:line` that
  owns the detail.
- **Out:** implementation detail, decisions, procedures, current state. Those are
  their own notes — a glossary that becomes a spec stops being a glossary.

Sharpen a glossary the moment a term proves fuzzy: when a word is doing two jobs
("account" meaning both the customer and the login), pick the canonical one, say
which is which, and record it then rather than batching it. When a term in the
note conflicts with how it is being used in conversation, say so — that conflict
is the whole reason the note exists.

## Maintenance

```bash
memory index          # reconcile INDEX.md with notes (add new, drop deleted, re-sort)
memory index --check   # report drift without writing (exit 1 if out of sync)
memory lint            # validate frontmatter, INDEX sync, and [[wikilink]] resolution
```

`index` is a **reconciler**, not a regenerator: it preserves curated hook/title text on existing lines, only adding lines for new notes and dropping orphans. Run it after creating notes by hand (with `Write` instead of `add`), and run `lint` before committing.

## Adding new commands

New subcommands go in the `memory` CLI (Ruby, stdlib only — no gems), documented above, with any new capability reflected in the front-matter `description`. The store root is a single `CORPUS_DIR` constant.

**Rule of thumb:** anything deterministic and procedural (frontmatter, index upkeep, validation) belongs in the CLI. Anything that needs judgment (*which* note applies on recall, *what* is durable enough to record, *what* the body says) stays with the agent — prose here, not code.
