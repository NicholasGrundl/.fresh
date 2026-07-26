# Archive Log

Append-only record of everything moved into `archive/`. Files keep their original names; this log
explains what and why. Newest first.

Each entry: `YYYY-MM-DD` · `path(s)` · short why.

---

## 2026-07-25 — spine re-based from metrochat onto .fresh

This `_snap/` was copied into `.fresh` as a **working copy from metrochat**, carrying that
project's live state. Re-pointed it to be `.fresh`'s own active workspace. Content below was
overwritten rather than moved into `archive/` — metrochat's repo remains the durable record, so
nothing is actually lost. Logged here because the "never silently delete history" rule applies to
overwrites too.

- **`ROADMAP.md`** — metrochat's roadmap (metro-map idea, auto-summarize + search summaries;
  last updated 2026-06-15, config re-center shipped, next was PLAN LanceDB).
- **`SESSION.md`** — mid-flight metrochat session: "TUI heatmap: live-populate + real summaries
  in detail".
- **`ALIGNMENT.md`** — `Last run: 2026-06-15 — post-0.1.0 reconciliation closed; spine clean.`

`AGENTS.md`, `features/AGENTS.md`, `features/BACKLOG.md`, `context/AGENTS.md` and everything under
`skills/` were already project-agnostic and were **not** touched. Entries below this line are
metrochat's and are retained for provenance.

## 2026-06-13 — great-docs shipped spec

Feature is `[done]` and shipped (see `ROADMAP.md` "Done" + `DECISIONS.md` 2026-06-13, tasks 1–7).
Archived to clear the working `features/` list now that the doc site + acceptance gate are in
place. Filename keeps its `[done]` prefix; ROADMAP/DECISIONS remain the durable record.

- **`archive/[done]great-docs.md`** — Quarto/quartodoc/griffe doc site: curated 11-symbol public
  surface, README landing + architecture/CLI pages, green `build`/`check-links`/`scan`/`preview`,
  whole-codebase docstring sweep to Google-style. Gated the 0.1.0 release (shipped 2026-06-13).

## 2026-06-13 — shipped feature specs (pre-great-docs housekeeping)

Both features are `[done]` and shipped (see `ROADMAP.md` "Done" + `DECISIONS.md` 2026-06-12/13).
Archived to clear the working `features/` list before starting great-docs. Filenames keep their
`[done]` prefix per the "files keep their original names" rule; ROADMAP/DECISIONS remain the
durable record of what shipped.

- **`archive/[done]config-file-and-ignore-rules.md`** — five-layer ignore engine + `metrochat.yaml`
  project config + `metrochat init` scaffolding (shipped 2026-06-13).
- **`archive/[done]file-types-and-content-extraction.md`** — yaml/json/csv/PDF/docx coverage +
  LLM content budget + `extract.py` seam (shipped 2026-06-12).

## 2026-06-02 — `_snap` refactor, Pass 3 (legacy `[draft]` triage)

Triage of pre-system `[draft]`s found in `features/`. Filenames kept as-is (incl. the now-moot
`[draft]` prefix) per the "files keep their original names" rule.

- **`archive/[draft]phase-3-refactoring.md`** — a *completed* design doc (Phase 3A+3B finished
  2025-11-23, "all 180 tests pass"); it describes the three-layer architecture that now exists in
  `src/`. Historical record, not queued work.
- **`archive/[draft]blueprint_system_refinement.md`** — the original "TODO _blueprint" seed
  brain-dump that *became* the `_snap` refactor (Passes 1–3); fully absorbed into `AGENTS.md` /
  the snap-refactor spec / `BACKLOG.md`.
- **`archive/[draft]prompt_for_test_suite_review.md`** — a spent one-off prompt used to generate
  the test-suite review.
- **`archive/[draft]test-suite-review.md`** — the review's findings; actionable recs distilled
  into a `features/BACKLOG.md` entry ("test-suite refinements") before archiving.

Not archived — **relocated** (logged here for the trail): the two bookmark security-research docs
moved from `features/` to `context/bookmarks/` (`file-format-risks.md`, `url-security-risks.md`)
as durable domain reference; a `BACKLOG.md` entry ("bookmark security & privacy audit") points at
them.

## 2026-06-02 — `_snap` refactor, Pass 2

- **`archive/PROMPT-refactor_and_CLEAN.md`** — the original kickoff brief that seeded the entire
  `_snap` refactor (the user's two-part "overhaul the blueprint system + clarify the bookmark
  project" request). A one-off seed prompt, not a reusable session playbook — its intent is
  captured in `DECISIONS.md`. Moved out of `prompts/` so that folder holds only the unified
  playbooks (interview-and-plan / orient-and-implement / reconcile-and-align) + `AGENT-html-fetcher`.

## 2026-06-02 — `_snap` refactor, Pass 1

- **`archive/commands/`** (9 files: `commit-auto`, `commit-macro`, `commit-manual`,
  `design-plan`, `design-review`, `tasks-align`, `tasks-implement`, `work-archive`,
  `work-status`) — the old `.claude/commands/*` slash-commands. Retired: their
  session-orchestration role moves to the unified prompts (PLAN / BUILD / ALIGN), and the
  commit/git pieces fold into the planned `git-session-infra` (hooks + skill). Kept for
  reference/salvage during that rebuild.
- **`archive/TASKS-TODO.md`** — bookend's completed Phase-3 refactoring task list. Superseded by
  the feature/ROADMAP model; retained as historical record.

## Pre-existing (grandfathered from the old `_blueprint/archive/`)

These were already archived before the refactor; logged here for completeness:
`chrome_bookmarks_format_spec.md`, `mvp_1.1_foundation.md`, `phase-1-data-model.md`,
`phase-2-cli-search-tools.md`, `phase-2.5-cli-ergonomics.md`, `project_plan.md`,
`review_fixes_summary.md`.
