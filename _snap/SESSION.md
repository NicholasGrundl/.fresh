# Session — .fresh overhaul: orientation & structure agreement

*The present — an ephemeral working scratchpad.*

## Focus

Survey the repo, agree the target structure, stand up this workspace. **No files moved yet.**

## Done this session

- [x] Surveyed the repo — 311 files, prior `bootstrap/core/library` reorg complete but
      `REORG_PLAN.md` left stale at root; leftovers (`macos/` with only `.DS_Store`, root
      `.gitignore_global`, `opencode.json`).
- [x] Diagnosed `_snap/` — sound design, but this copy carries **metrochat** state.
      `prompts/` duplicates `skills/snap/references/` byte-for-byte (3 pairs).
- [x] Diagnosed `library/ai/claudecode/` — 99 files, **41 unique**. Not 6 projects' ideas;
      **two generations of one system**, and gen 2 *is* `_snap`.
- [x] Read jxnl/dots (`~/projects/+forks/dots`) — took the flag-driven idempotent installer,
      first-class `agents/` section, fan-out install, and `tests/` harness. Rejected its
      single-OS assumption.
- [x] Agreed target structure + the OS model (see `DECISIONS.md` 2026-07-25).
- [x] Reset this spine from metrochat → .fresh; wrote the Phase 0–4 roadmap.

- [x] Refused `misc/`; wrote `features/[ready]destination-map.md` assigning every existing path
      a destination. `bootstrap/`, `core/`, `library/`, `prompts/`, `macos/` all dissolve.
- [x] Added Phase 2.5 (`snap-init` bootstrap-by-agent) and the `AGENTS.md` symlink mechanism.

## Next

Phase 0 — **user is landing the checkpoint commit by hand.** No `mv` until it lands.

Then **two blockers** gate the first moves (both in ROADMAP open questions):

1. **Cross-OS identical payloads** — ~14 files are one copy today; pure OS-major makes them
   three. Blocks the `machine/` moves (T1).
2. **`templates/` as a fourth category** — `library/templates/*` is project scaffolding, not
   machine/agents/context. Blocks T4.

`agents/`, `context/`, and `_archive/` moves (T2/T3/T5) are unblocked and can run first.

## Notes / gotchas

- `_snap/AGENTS.md` is generic and clean — it survived the reset untouched, it's the real
  design doc.
- `_snap/context/CLAUDE.md` is a genuine symlink → `AGENTS.md`. Preserve symlink-ness through
  any move; a naive `cp` will silently fork it into a duplicate file.
- Honor `_snap`'s own conventions during the overhaul: **moves are sacred** (each `git mv`
  its own commit, never bundled with content edits), and **nothing is silently deleted** —
  removals get an `archive/ARCHIVE.md` entry.

_Last flush:_
