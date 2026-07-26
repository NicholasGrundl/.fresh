# `features/` — Conventions

This folder holds **feature specs** — the unit of work in `_snap`. One file per feature.

## Filename & state

`[<state>]<descriptive-name>.md` — the state prefix is the scannable signal.

- **`[draft]`** — being planned; not ready to build.
- **`[ready]`** — planned & queued; has exec overview + task checklist.
- **`[active]`** — currently being built.
- **`[done]`** — complete (archive when convenient).
- **`[deprecated]`** — abandoned or needs realignment.

Mirror the state in YAML frontmatter so tools can read it without opening the body:

```yaml
---
state: ready          # draft | ready | active | done | deprecated
changelog:
  "YYYY-MM-DD HHh": "newest change"
---
```

## Document structure (once `[ready]`)

1. **Executive Overview** — *what it is and why* (+ non-goals).
2. **Task Checklist** — concrete, **testable** steps, ordered. This is the durable plan.
3. **Details** — all planning/implementation detail accumulated moving `[draft]→[ready]`.

**Sub-tasks are NOT written here.** They're decomposed just-in-time into `SESSION.md` when a
task is picked up during a BUILD session.

## Lifecycle

- `[draft]→[ready]`: lock the exec overview + task checklist; capture details. Add to `ROADMAP.md`.
- `[ready]→[active]`: start building (this flip *is* the "begin implementation" step).
- `[active]→[done]`: all tasks ticked; flush session notes to `DECISIONS.md`.

## `BACKLOG.md`

Unscheduled ideas. When one is committed, promote it to a `[draft]` spec here and add it to
`ROADMAP.md`. Use the item template documented at the top of `BACKLOG.md`.
