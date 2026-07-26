# `_snap` — AI Operating Environment

`_snap` is a **portable, per-project workspace** for AI-assisted development: cross-session
memory, session playbooks, reusable skills, and external reference context. Copy it into a
project, purge what you don't need, and work.

> This file is the **single source of truth** for how `_snap` is organized. `CLAUDE.md` (and any
> `GEMINI.md`) are symlinks to it. If a README or other doc disagrees with this file, this file
> wins.

## Filetree

```
_snap/
  AGENTS.md          # this file — system overview + conventions   (CLAUDE.md → symlink)
  ROADMAP.md         # FUTURE  — ordered list of features to build
  SESSION.md         # PRESENT — ephemeral session scratchpad (flushed at close)
  DECISIONS.md       # PAST    — append-only, culled decision log + history (onboarding)
  ALIGNMENT.md       # drift/replan triage report
  context/           # external reference docs, one subfolder per topic   (+ AGENTS.md)
  features/          # feature specs <name>.md + conventions               (+ AGENTS.md)
    BACKLOG.md       #   unscheduled feature ideas
  prompts/           # session playbooks (PLAN / BUILD / ALIGN) — copied in per project
  skills/            # portable skill library (activate by copy/symlink → .claude/skills)
  reference/         # temp dumping ground (images, snippets, transcripts)
  archive/           # ARCHIVE.md (append-only log) + archived files
```

## Cross-session memory — future / present / past

The three core files are the same system at different zoom levels:

- **`ROADMAP.md`** — *future*: ordered features to build; "phases" are ephemeral grouping labels only.
- **`SESSION.md`** — *present*: the current session's working scratchpad — sub-tasks, in-flight
  reasoning. Wiped at flush.
- **`DECISIONS.md`** — *past*: append-only, culled log — *what we set out to do / why / how it
  ended / why we stopped*. Read this to onboard.

`ALIGNMENT.md` is produced by ALIGN sessions to triage drift between docs and reality.

**Native AI memory (e.g. `MEMORY.md`) is OFF by preference.** Project state lives here, in files
you can see and control — not in opaque memory.

## The work lifecycle (run via `prompts/`)

```
PLAN   idea ─interview→ features/<name>.md  [draft]→[ready];  add it to ROADMAP
BUILD  [ready]→[active]; pick a task ─just-in-time→ sub-tasks in SESSION.md; commit as you go
       CLOSE → flush SESSION ─condense→ DECISIONS; tick task checkboxes; bump ROADMAP
ALIGN  reconcile ROADMAP / features / SESSION / DECISIONS vs reality → ALIGNMENT.md
```

**Tiers:** *Feature* is the unit of work (a doc in `features/`). *Tasks* are its concrete,
testable checklist items. *Sub-tasks* are session-level steps, decomposed just-in-time into
`SESSION.md` — never pre-listed. *Phases* are only sequencing labels in `ROADMAP.md`.

## The git axis (separate from the memory files)

Git carries **file-level change intelligence**, orthogonal to the memory files:
- **micro commits** — per-file change detail; intended to capture intent/gotchas for future LLMs.
- **macro commits** — human-readable checkpoints at task/feature boundaries (≈ a DECISIONS entry).

## Conventions

- **Moves are sacred:** every `mv`/`git mv` is a **separate, individually-approved** operation,
  committed on its own — never bundled with content edits.
- **Rules:** `AGENTS.md` is canonical in every folder that has rules; `CLAUDE.md` is a symlink.
- **Portability:** per-project copy. Copy `_snap`, delete what the project doesn't need.
- **Archive:** never silently delete history — append an entry to `archive/ARCHIVE.md`
  (timestamp + path(s) + why); files keep their names.
- **Skills:** `skills/` is a *library*. Activate a skill by copying/symlinking it into
  `.claude/skills/`.
- **Context:** see `context/AGENTS.md` — search subfolder *names* first; don't bulk-read.
- **Features:** see `features/AGENTS.md` — frontmatter state, doc structure, naming.
- **Formatting:** avoid wide markdown tables (they don't wrap in narrow windows) — prefer
  list/section layouts.
