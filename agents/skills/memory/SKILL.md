---
name: memory
description: >-
  The shared, tool-agnostic memory store at ~/Code/memory/knowledge/ — durable markdown notes (facts, procedures, conventions, patterns, gotchas, per-repo glossaries).
  RECALL before re-deriving something already solved (`memory list --topic …`, then read the matching note). RECORD durable knowledge with `memory add`.
  Use at the START of any task that smells already-handled, or when you learn something worth keeping.
  Topics — none yet (read INDEX.md).
---

# memory

The memory store is the shared knowledge base at `~/Code/memory/knowledge/` — plain, git-tracked markdown notes (one fact/procedure/convention per file) with YAML frontmatter (`type`, `tags`, `created`). Any tool can read and write it. It is **not** auto-loaded into context; you reach a note on demand. (Episodic archives of completed work live alongside in `~/Code/memory/log/` — history, not recall.)

Notes carry two **facets** as nested tags: `topic/<name>` (a curated taxonomy — the names in this skill's description, defined in `TOPICS.md`) and `repo/<org>/<repo>` (which repo the note concerns). Other tags are free-form.

## Recall — route, then read

Recall is judgment: you pick the topics and the notes; the CLI only filters.

1. **Pick topics** from the description's `Topics —` list that could bear on the task. Pick generously — a spare topic costs a few lines.
2. **`memory list --topic a,b`** — prints the matching notes' `INDEX.md` lines (title, hook, facets). It also adds notes for the repo you're in (detected from the checkout, or every repo under `.worktrees/` at a workspace root) and `unfiled` notes. `--repo org/repo` overrides detection; `--no-repo` skips it.
3. **Read** the note(s) whose line matches the task.
4. **Fall back** when nothing fits, or the list says `none yet`: `rg <term> ~/Code/memory/knowledge/`, then read all of `INDEX.md`. Its lines end in `· topic/… repo/…`, so `rg 'repo/vimeows/vimeo' INDEX.md` filters without the CLI.

Do this at the **start** of work, or whenever a question smells already-answered:
- "have we hit this before?" before debugging or re-deriving
- a known **convention** (code style, commit types, CI layout), **procedure** (deploying a service, rotating a credential), **fact/topology** (which datastore is canonical, the service dependency graph), or **gotcha** (a flaky test, a config that won't load locally)

## Record — `memory add`

When you learn something durable and reusable beyond the current task, record it. The `memory` CLI (on `PATH`) owns only the *deterministic* parts (schema-correct frontmatter, today's date, facet validation, keeping `INDEX.md` in sync) — covered by `Bash(memory:*)`, so it runs without a prompt.

```bash
memory add \
  --slug ci-uses-shallow-clones \
  --type reference \
  --tags "topic/ci, topic/git, repo/vimeows/vimeo, shallow-clone" \
  --title "CI uses shallow clones" \
  --summary "the build runner fetches depth=1; deepen before any tag-describe step or it fails."
```

This writes `~/Code/memory/knowledge/<slug>.md` with correct frontmatter and registers its `INDEX.md` line. Then **fill in the body** (Edit/Write — that's the knowledge, your judgment) and **commit in `memory/`** (commits are by hand, so you control the message and grouping).

- `--type` ∈ `reference` (a fact / how-things-are) · `procedure` (a how-to) · `convention` (a normative standard) · `pattern` (general/transferable) · `identity` (a person) · `glossary` (see below). One fact per note; link related notes with `[[slug]]` wikilinks.
- `--summary` becomes the `INDEX.md` hook, which every recall reads in full. Write it as a **pointer** (≤150 chars, enforced): what the note is and when to reach for it, trigger words first. The detail belongs in the body.
- **Topics:** at least one `topic/<name>` from `memory topics` (enforced once `TOPICS.md` exists). **Over-assign** — a missing topic makes the note unreachable by routing; a spare one costs a line. When none fits, use `topic/unfiled`; the `librarian` places it later. Never add a topic to `TOPICS.md` yourself — the taxonomy is the librarian's.
- **Repo:** add `repo/<org>/<repo>` for each repo the note concerns.

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
memory index          # reconcile INDEX.md with notes (add new, drop deleted, re-sort, regenerate facets)
memory index --check   # report drift without writing (exit 1 if out of sync)
memory topics          # the taxonomy, with note counts
memory topics --sync   # copy topic names into this skill's description (then commit in ~/.dotfiles)
memory lint            # validate frontmatter, facets, taxonomy bounds, INDEX + description sync, wikilinks
```

`index` is a **reconciler**, not a regenerator: it preserves curated hook/title text on existing lines, only adding lines for new notes, dropping orphans, and rewriting each line's trailing facets from frontmatter. Run it after creating notes by hand (with `Write` instead of `add`) or changing a note's tags, and run `lint` before committing. Lint warnings that start `librarian pass due:` mean the taxonomy has drifted out of bounds — run `/librarian`.

## Adding new commands

New subcommands go in the `memory` CLI (Ruby, stdlib only — no gems), documented above, with any new capability reflected in the front-matter `description`. The store root is a single `CORPUS_DIR` constant. Tests: `ruby ~/.dotfiles/agents/skills/bin/test/memory_test.rb`.

**Rule of thumb:** anything deterministic and procedural (frontmatter, index upkeep, validation) belongs in the CLI. Anything that needs judgment (*which* note applies on recall, *what* is durable enough to record, *what* the body says) stays with the agent — prose here, not code.
