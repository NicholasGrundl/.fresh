---
state: ready
changelog:
  "2026-07-25 16h": "initial map — every existing path assigned a destination; no misc/"
---

# Destination Map

## Executive Overview

**What:** an exhaustive assignment of every existing path in `.fresh` to a destination in the new
structure. One row per current path; nothing is unassigned.

**Why:** `misc/` was explicitly refused. That refusal only holds if every file has a home decided
*before* the moves start — otherwise the first awkward file recreates `misc/` under another name.
This is also the checklist the moves execute against, one `git mv` per commit.

**Non-goals:** this does not refresh stale config *content* (deferred, Phase 4) and does not split
the README body (Phase 4). It only decides where things live.

## Task Checklist

- [ ] T1 — `machine/` moves (bootstrap + core, per OS)
- [ ] T2 — `agents/` moves (prompts, .claude, library/ai)
- [ ] T3 — `context/` moves (`_snap/context/` + reference docs)
- [ ] T4 — `templates/` moves — **blocked** on the fourth-category question
- [ ] T5 — `_archive/` moves (duplicates + completed planning artifacts)
- [ ] T6 — deletions (`.DS_Store`, empty dirs)
- [ ] T7 — resolve the two blockers, then re-run T1/T4

## Details

### → `machine/`

- `bootstrap/linux/setup.sh`, `packages.txt` → `machine/wsl/`
- `core/bash/.bashrc.linux`, `.profile`, `.bash_logout` → `machine/wsl/`
- `bootstrap/macos/README.md` (🚧 placeholder stub) → **merge into**
  `machine/macos/SETUP.md`, whose real content comes from `library/docs/macos/README.md`
- `core/bash/.bashrc.macos`, `.bash_profile.macos` → `machine/macos/`
- `bootstrap/windows/install.ps1`, `uninstall.ps1` → `machine/windows/`
- `core/powershell/{profile,DiagnosticFunctions,EnvFunctions,SSHFunctions}.ps1` → `machine/windows/`
- `library/docs/windows/{README,Node_installation}.md` → `machine/windows/SETUP.md`
- `bootstrap/common/check_health.sh` → split per-OS as `machine/<os>/check.sh`
- `core/bash/.bashrc` (the un-suffixed one) → **decide**: it is the base that `.linux`/`.macos`
  varied from. Under OS-major it dissolves into each OS's own bashrc.

**Blocked — cross-OS identical payloads.** These are one copy today with no OS variant, and
OS-major turns 1 into 3: `core/git/{.gitconfig,.gitignore_python,.gitignore_windows}`, root
`.gitignore_global`, `core/starship/*.toml` (6), `core/vscode/settings.json`,
`core/jupyter/jupyter_lab_config.py`, `core/python/.condarc`,
`core/bash/.bash_custom_functions`. ~14 files. See ROADMAP open questions.

### → `agents/`

- `.claude/` (commands, agents, hooks, status_line_custom.py) → `agents/claude/` — the live config
- `prompts/review-agents.md` → `agents/prompts/`
- `prompts/{DEFAULT_GEMINI_SYSTEMPROMPT,gemini-thinking-text}.md` → `agents/reference/gemini/`
- `library/ai/claudecode/` → `agents/reference/mine-v1/` (41 unique) + `_archive/` (58 dupes)
- `library/ai/claudecode/*/hooks/lib/` → `agents/hooks/` — **in-development, not `_snap` canon**
- `library/ai/ollama/{opencode.json,README.md}` + root `opencode.json` → `agents/opencode/`
  (root copy and `library/ai/ollama/` copy must be diffed first — likely identical)
- `library/ai/docs/{local_llm*,promptify,sql-prompt}.md` → `agents/reference/local-llm/`
- `library/ai/articles/how-i-ai-podcast-hooks.md` → `agents/reference/articles/`
- `GEMINI.md` → dissolves; root gets `AGENTS.md` + `CLAUDE.md`/`GEMINI.md` symlinks
- `~/projects/+forks/dots` → vendored to `agents/reference/jxnl-dots/`
- `_snap/skills/` core `snap-*` → `agents/snap/skills/`; `playwright-cli` → `agents/skills/`

### → `context/`

- `_snap/context/*` (24 topics) → `context/` — minus the two empty dirs
- `prompts/claude-code-anecdotes/` (9 files) → `context/claude-code/` — it is reference material
  on Claude Code internals, not a prompt library. Currently misfiled by name only.
- `prompts/github_cli_via_rest.md` → `context/gh/`

### → `templates/` *(blocked — fourth category)*

- `library/templates/python/` (Makefile, pyproject, requirements×3, setup.cfg)
- `library/templates/conda/base.yml`
- `library/templates/nvm-uv/` (.gitignore, .nvmrc.example, DEVELOPMENT.md)

Project scaffolding — not machine setup, not agent assets, not reference docs. Needs its own
top-level home or an explicit merge decision.

### → `_archive/`

- `REORG_PLAN.md` — the *previous* reorg, complete; left stale at root for six months
- `library/planning/logs/{actions_reorg_completed.md,movement_log.txt}` — same reorg's logs
- `library/planning/TODO.md` — Jason Liu workshop notes; the origin of the jxnl/dots reference.
  Mine for roadmap items first, then archive.
- the 58 duplicate files from `library/ai/claudecode/`

### → deleted

- 11 tracked `.DS_Store` files (+ root `.gitignore` to stop the bleeding)
- `macos/` — contains only `.DS_Store` and an empty `vscode/`
- `_snap/context/{antigravity-cli,direnv}/` — empty
- `_snap/prompts/*.md` — byte-identical to `_snap/skills/snap/references/*.md` (3 pairs);
  the template keeps exactly one home

### Emptied by the above

`bootstrap/`, `core/`, `library/`, `prompts/`, `macos/` all disappear.
