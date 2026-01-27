# Claude Code Projects - Maturity Summary

> Generated 2026-01-27. All projects share the same git commit date (2026-01-26) due to bulk repo reorganization.

## Tier 1 - Most Mature

| Project | Size | Files | Key Differentiator |
|---|---|---|---|
| **bizwiz** | 200 KB | 23 | Full modular hooks lib (8 scripts), 9 commands, comprehensive README |
| **bookend** | 196 KB | 22 | Nearly identical to bizwiz — likely a shared production template |

Both have a deep `.claude/hooks/lib/` directory with modular shell scripts, templates, and thorough documentation following Unix pipeline philosophy.

## Tier 2 - Mature / Specialized

| Project | Size | Files | Key Differentiator |
|---|---|---|---|
| **resumeradar** | 172 KB | 19 | Uses `.claude/tools/` instead of hooks — customized variant |
| **minutia** | 88 KB | 10 | Python-focused with `review-tests.md` (27 KB) and `update-docstrings.md`; has experimental `macro-commit-refactored.sh` |

## Tier 3 - Functional but Minimal

| Project | Size | Files | Key Differentiator |
|---|---|---|---|
| **personalsite** | 124 KB | 11 | Core commands present, only 2 hooks, no modular lib |
| **.fresh** | 120 KB | 12 | Baseline template — intentionally minimal |

## Tier 4 - Stub

| Project | Size | Files | Key Differentiator |
|---|---|---|---|
| **cascadebio** | 4 KB | 1 | Only `settings.local.json` — placeholder |

## Notable Findings

- **bizwiz** and **bookend** are nearly identical, suggesting a standardized "gold template" pattern. Either works as the canonical reference.
- **minutia** is the most *specialized* despite being smaller — it has unique Python-centric commands not found elsewhere and shows active iteration (refactored hooks alongside originals).
- **resumeradar** diverges from the standard by using `.claude/tools/` instead of `.claude/hooks/` for its modular automation scripts.
