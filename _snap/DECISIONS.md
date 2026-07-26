# Decisions

Append-only, culled log of what was done and why — the **past**. Read this to onboard. Each entry:
*what we set out to do / why / how it ended / why we stopped*. Newest first.

Session scratch lives in [`SESSION.md`](./SESSION.md); it is condensed into here at session close.

---

## 2026-07-25 — adopt `_snap` here; agree the .fresh overhaul structure

**Set out to:** overhaul `.fresh` — the dotfiles / fresh-compute / bootstrapping repo. Three
things had accreted without a plan: machine provisioning, agentic AI assets, and reference docs.

**Why:** the tree was organized tool-centric and fell apart on OS specifics; four overlapping AI
hierarchies (`_snap/`, `prompts/`, `library/ai/`, `.claude/`) had no rule for what lives where;
and there was no install mechanism at all — the 890-line README said "copy this file to there."

**Decided:**

- **Three sections, explicitly separate.** `machine/` (provisioning — a friend can match the
  setup), `agents/` (AI workflow assets), `context/` (manually curated package docs — a local
  Context7). Plus `misc/` for untriaged content and `_archive/` for removals pending review.
- **OS-major, no `shared/` layer.** Considered a layered `shared/` + OS-overlay install; rejected
  it as over-optimistic — brew vs. apt vs. winget/PowerShell means very little is *ever* truly
  shared even when the tool is the same. Each OS gets a self-contained full install; the root
  `install.sh` detects the OS and delegates.
- **Every OS folder ships two paths:** an install script *and* a human-readable `SETUP.md` with
  the commands one at a time — so someone can learn the setup instead of auto-running it.
- **Copy, never symlink.** Symlinks would give live two-way editing but break on Windows without
  admin/dev-mode, and WSL + PowerShell are both in scope. Mitigate the loss of write-back with
  `--backup` and a `--diff` flag that reports repo↔machine drift.
- **Windows is lowest priority** and is genuinely PowerShell (`.ps1`, different config
  locations) — *not* "run the Linux path under WSL."
- **`context/` leaves the `_snap` template.** Canonical `_snap` ships an empty `context/` with
  only its convention doc; the real library is top-level `context/`, cherry-picked into a
  project after copying `_snap` in. Keeps the template from getting heavier every copy.
- **`_snap` stays copy-per-project**, sync back to canonical managed by hand.
- **Commit hooks are not canon yet.** The `hooks/lib/` LLM-summarize commit machinery is the one
  thing worth keeping from the v1 `.claude/` generation, but it's still in development — it
  lands in `agents/hooks/`, explicitly *not* in the canonical `_snap` template.
- **Nothing is deleted outright.** Removed duplicates go to `_archive/` for review.
- **No `misc/`.** Proposed as a pressure valve, then refused — correctly. The evidence was
  already in the tree: the *previous* reorg left `REORG_PLAN.md`, a `macos/` folder holding one
  `.DS_Store`, and a stray `.gitignore_global` at root for six months. Instead, every existing
  path is assigned a destination up front in `features/[ready]destination-map.md`.
- **`AGENTS.md` is canonical; `CLAUDE.md`/`GEMINI.md` are symlinks to it** — they're generally
  the same file, so maintaining three is waste. Needs a *mechanism* that creates them wherever
  an `AGENTS.md` exists, degrading to copy on Windows.
- **Bootstrap by agent, not by script (`snap-init`).** The lightest-touch path for a
  non-technical user is: copy `_snap` in, install a CLI agent via curl, launch it, and let *it*
  verify and finish the setup — rather than trying to script every case. A new `_snap` skill
  (the init assistant) does the verification, symlink wiring, template purge, spine seeding, and
  context selection. Noted chicken-and-egg: the skill lives inside `_snap`, so a small external
  entrypoint has to do the copy + agent install first. `curl | bash` must not be the only path —
  it needs the readable `SETUP.md` twin, same rule as the OS installers.

**Findings that drove this:**

- `library/ai/claudecode/` is 99 files but only **41 unique**. It is not six projects' worth of
  ideas — it is **two generations of one system**, and generation 2 *is* `_snap`
  (`design-plan`→PLAN, `tasks-implement`→BUILD, `tasks-align`→ALIGN, `work-status`/`work-archive`
  → the ROADMAP/SESSION/DECISIONS spine). Only resumeradar genuinely forked.
- The `_snap/` dropped into this repo was a **working copy from metrochat**, not a template —
  its ROADMAP/SESSION/ALIGNMENT carried live metrochat state. `AGENTS.md` was already generic.
- Tool-centric layout didn't fail on its merits; it failed *without an installer*. `core/bash/`
  held `.bashrc`, `.bashrc.linux`, and `.bashrc.macos` with nothing to decide between them.

**Reference adopted:** jxnl/dots (`~/projects/+forks/dots`) — took its flag-driven idempotent
installer (`--dry-run`/`--backup`/`--interactive`, `cmp -s` skip-if-identical), its first-class
`agents/` section with a delegating sub-installer, its fan-out install (one prompt source → N
tool targets), and its `tests/` harness. Rejected its single-OS (macOS/zsh) assumption.

**Ended:** structure agreed; this spine re-based from metrochat onto .fresh; Phase 0–4 roadmap
written. **Stopped** before moving any files — 119 files are staged-but-never-committed, so
there is no restore point yet. Phase 0 is the checkpoint commit.

