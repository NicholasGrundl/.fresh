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

## Next

Phase 0 — **awaiting user go-ahead on the checkpoint commit.** 119 files are staged and
never committed; no restore point exists, so no `mv` should happen before that lands.

## Notes / gotchas

- `_snap/AGENTS.md` is generic and clean — it survived the reset untouched, it's the real
  design doc.
- `_snap/context/CLAUDE.md` is a genuine symlink → `AGENTS.md`. Preserve symlink-ness through
  any move; a naive `cp` will silently fork it into a duplicate file.
- Honor `_snap`'s own conventions during the overhaul: **moves are sacred** (each `git mv`
  its own commit, never bundled with content edits), and **nothing is silently deleted** —
  removals get an `archive/ARCHIVE.md` entry.

_Last flush:_
