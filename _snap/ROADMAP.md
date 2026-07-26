# Roadmap

Ordered list of features to build for **.fresh** — the dotfiles / fresh-compute / bootstrapping
repo. Three products in one tree: **machine provisioning** (a friend can match my setup),
**agentic AI workflow assets** (the canonical `_snap` + skills + prompts), and a **manually
curated context library** (a local Context7). The order *is* the plan; "phases" are just
grouping labels. Detail for any feature lives in its `features/<name>.md` spec; history lives
in [`DECISIONS.md`](./DECISIONS.md).

*Last updated: 2026-07-25 (structure agreed + full destination map; no `misc/` — every file
gets a home. Nothing moved yet.)*

---

## Phase 0 — Safety net

Nothing moves until there is a restore point. 119 files are staged-but-never-committed.

- `[active]` **checkpoint-commit** — user is landing this by hand.
- `[ready]` **repo-hygiene** — add a root `.gitignore`; untrack the 11 committed `.DS_Store`
  files; delete `macos/` (contains only `.DS_Store` + an empty `vscode/`).

## Phase 1 — Skeleton

- `[ready]` **top-level-skeleton** — create `machine/`, `agents/`, `context/`, `templates/`,
  `_archive/`. A README in each stating what belongs there and what doesn't.
  **No `misc/`** — deliberately refused; every existing file has an assigned destination
  (see `features/destination-map.md`). The last reorg's leftovers (`REORG_PLAN.md`, a `macos/`
  folder holding one `.DS_Store`, a stray `.gitignore_global`) are what a `misc/` becomes.

## Phase 2 — Agents consolidation

Collapse four overlapping AI hierarchies (`_snap/`, `prompts/`, `library/ai/`, `.claude/`)
into one `agents/` section.

- `[ready]` **extract-canonical-snap** — lift a clean `_snap` template into `agents/snap/`:
  generic spine, empty `context/` (convention doc only), core `snap-*` skills. Zero project
  state. This repo's `_snap/` stays the *active* workspace, not the template.
- `[ready]` **context-library** — move the 24 `_snap/context/` topics to top-level `context/`.
  Drop the two empty dirs (`antigravity-cli/`, `direnv/`). Establishes the cherry-pick model:
  copy `_snap` into a project, then pull context topics in as needed.
- `[ready]` **consolidate-claudecode-snapshots** — 99 files → 41 unique. One consolidated v1
  snapshot + resumeradar's genuine fork into `agents/reference/mine-v1/`; the 58 duplicates to
  `_archive/` for review rather than deletion.
- `[ready]` **promote-commit-hooks** — the `hooks/lib/` LLM-summarize commit machinery has no
  `_snap` equivalent. Lands in `agents/hooks/` as **in-development**; explicitly *not* in the
  canonical `_snap` template yet.
- `[ready]` **fold-loose-ai-files** — root `prompts/`, `.claude/`, `GEMINI.md`,
  `opencode.json`, `library/ai/*` into `agents/`. Per the destination map.
- `[ready]` **vendor-reference-approaches** — `agents/reference/jxnl-dots/`. Other people's
  approaches quarantined so they can't be mistaken for canon.

## Phase 2.5 — `snap-init`: bootstrap-by-agent

The lightest-touch path for a non-technical user: don't script the setup, **let an agent do it**.
Copy `_snap` in, install a CLI agent, launch it, and have it verify and finish the job.

- `[draft]` **agent-doc-symlinks** — `AGENTS.md` is canonical; `CLAUDE.md` and `GEMINI.md` are
  symlinks to it. Need a mechanism that creates them wherever an `AGENTS.md` exists, rather
  than hand-maintaining them. Must degrade to copy on Windows (symlinks need admin/dev-mode).
  Also the guard against a naive `cp -r` silently forking a symlink into a duplicate file.
- `[draft]` **snap-init-skill** — a new `_snap` skill: the init assistant. Verifies the copied
  template, wires the symlinks, purges what the project doesn't need, seeds the spine
  (ROADMAP/SESSION/DECISIONS) for the new project, and offers relevant `context/` topics.
- `[draft]` **snap-bootstrap-entrypoint** — the chicken-and-egg: `snap-init` lives *inside*
  `_snap`, so it can't run until `_snap` is copied and an agent exists. Needs one small
  curl-able script outside the system that copies the template + installs the agent CLI, then
  hands off to the skill. This is also the piece a non-technical user actually touches, so it
  needs the readable `SETUP.md` twin — do not make `curl | bash` the only path.

## Phase 3 — Machine provisioning

No `shared/` layer — package managers diverge (brew / apt / winget+PowerShell), so little is
ever *truly* shared. Each OS gets a self-contained full install.

Every OS folder ships **both** paths: an install script *and* a human-readable `SETUP.md` with
the commands one at a time, so a friend can learn instead of auto-installing.

- `[draft]` **machine-macos** — `install.sh` + `SETUP.md` + Brewfile + configs. The guide
  already largely exists at `library/docs/macos/README.md`; `bootstrap/macos/README.md` is a
  `🚧 PLACEHOLDER` stub for the same thing. Merge, don't write from scratch.
- `[draft]` **machine-wsl** — `install.sh` + `SETUP.md` + apt manifest + configs.
- `[draft]` **machine-windows** — `install.ps1` + `SETUP.md` + configs (genuinely PowerShell,
  different config locations — *not* "run the Linux path under WSL"). **Lowest priority.**
- `[draft]` **root-installer** — `install.sh` detects OS and delegates. Copy, never symlink.
  Flags: `--dry-run`, `--backup`, `--diff` (repo↔machine drift), per-component selection.
- `[draft]` **installer-tests** — shell test harness modeled on jxnl/dots `tests/`.

## Phase 4 — Docs

- `[draft]` **readme-split** — the 890-line / 24KB root README becomes a short landing page
  plus per-area docs. Most of its body (SSH setup, ollama tutorial, starship, conda) is
  per-area content that belongs in `machine/<os>/SETUP.md` or `agents/`.
- `[draft]` **refresh-stale-configs** — current `bashrc`/shell configs are likely stale vs. the
  live machine. Deliberately deferred; do not start before Phase 3.

---

## Open questions

- **Cross-OS identical payloads.** ~14 files exist as a *single* copy today with no OS variant
  (`core/git/*`, `core/starship/*.toml`, `core/vscode/settings.json`, `core/jupyter/`,
  `core/python/.condarc`, `core/bash/.bash_custom_functions`). Pure OS-major turns 1 copy into
  3. The rejected `shared/` was an *install* layer; this is only a *payload* question. Options:
  duplicate and police with `--diff`, or allow a narrow `machine/common/` for payloads only.
- **`templates/` is a fourth category.** `library/templates/{python,conda,nvm-uv}` is project
  scaffolding — not machine setup, not agent assets, not reference docs. Needs its own
  top-level home or an explicit merge decision.
- **Pull-back story.** `_snap` is copy-per-project; sync back to canonical is manual. Revisit
  once `agents/snap/` exists — the risk is a 7th divergent snapshot, which is exactly how
  `library/ai/claudecode/` happened.
