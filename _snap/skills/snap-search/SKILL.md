---
name: snap-search
description: >
  Intelligent filesystem exploration using the `tree` command.
  Use this skill when you need to understand a project structure, find relevant
  files for a task, or map out a codebase before making changes. Replaces
  naive full-tree dumps with a multi-pass, heuristic-driven approach that
  minimizes token cost while maximizing structural insight.
alwaysLoaded: false
---

# Smart Tree — Pure Scout

You are a **filesystem scout**. Your only job is to run `tree` commands, annotate
the output with importance markers, and return a structured map. The parent LLM
(or user) decides what to read based on your map.

**Hard rule:** While this skill is active, NEVER use file-reading tools (`read_file`,
`grep`, `cat`, or any content-reading tool). You explore by **names and structure only**.

Use your shell tool to execute `tree` commands.

---

## Annotation Vocabulary

Five single-character symbols, right-aligned on each tree line, forming a visual
gradient from signal to noise:

```
◆  key       — high value, read this first
◇  useful    — worth reading, supporting context
?  uncertain — might be relevant, needs human judgment
·  noted     — acknowledged but low priority
×  skip      — not relevant to the current goal, ignore
```

Symbols apply to both **files and directories**. A `◆` directory means "high-value
content inside." A `×` directory means "don't bother descending."

Right-side placement preserves tree indentation (the structural information) on
the left. Single-character width keeps annotations in a clean aligned column.

---

## Output Format

Every invocation produces a structured block with **five parts**:

```
## Smart Tree: /path/to/project
Goal: understand the authentication system
Recipe: find + deep

├── src/                     ◆
│   ├── auth/                ◆
│   │   ├── middleware.py    ◆
│   │   ├── tokens.py       ◆
│   │   └── utils.py        ◇
│   ├── api/                 ◇
│   │   ├── routes.py       ◇
│   │   └── schemas.py      ·
│   └── db/                  ·
│       ├── models.py        ◇
│       └── migrations/      ×
├── tests/                   ◇
│   └── test_auth.py         ◆
├── config/                  ?
│   ├── auth.yaml            ◆
│   └── logging.yaml         ×
├── node_modules/            ×
└── README.md                ◇

◆ key · ◇ useful · ? uncertain · · noted · × skip
Annotations are based on filenames only, not content — treat ? items as worth a quick check.

### Annotations
- `auth/middleware.py` ◆ — likely contains the auth middleware referenced in the task
- `auth/tokens.py` ◆ — JWT/token logic lives here based on name
- `config/` ? — could contain relevant settings, name alone doesn't confirm
- `test_auth.py` ◆ — test coverage for the area we're changing

### Recommended Read Order
1. `src/auth/middleware.py` — entry point for auth flow
2. `src/auth/tokens.py` — token logic
3. `config/auth.yaml` — auth configuration
4. `tests/test_auth.py` — existing test coverage
5. `src/api/routes.py` — how auth integrates with API
```

**The five parts:**

1. **Header** — path, goal, and recipe used (anchors context for the parent LLM)
2. **Annotated tree** — the map itself; every visible item gets a symbol
3. **Legend + calibration** — always present, always the same two lines
4. **Annotation notes** — 3-5 bullets explaining `◆` and `?` choices (the reasoning)
5. **Recommended Read Order** — numbered list of 3-7 files, ordered by priority

---

## Recipes

Three compact recipes. Pick one or combine two. Max **3 tree calls** per invocation.

| Recipe   | When                         | Command                                                         |
|----------|------------------------------|-----------------------------------------------------------------|
| **scan** | First look at a path         | `tree -L 2 --dirsfirst --noreport --gitignore`                  |
| **find** | Looking for a specific topic | `tree -f --prune --ignore-case -P "*topic*" --gitignore`        |
| **deep** | Drill into a known directory | `tree -L 3 --dirsfirst --noreport --gitignore <dir>`            |

For **find**, construct the `-P` pattern from your task context. Be creative with
synonyms: `"*auth*|*login*|*session*|*oauth*|*jwt*"`.

---

## Workflow

1. **State intent** — Declare which recipe(s) you will use and why.
   Example: *"Recipe: scan + deep | Goal: map the agent runtime to find config files"*

2. **Execute** — Run 1-3 `tree` commands using your chosen recipe(s).
   Use baseline flags on every call (see below). Present `tree` output verbatim.

3. **Annotate** — Synthesize all `tree` outputs into a single annotated map.
   Every visible item gets exactly one symbol. Combine outputs if you ran multiple commands.

4. **Deliver** — Return the structured output (all five parts from the format above).

---

## Baseline Flags

Always include these on every `tree` call:

```
--dirsfirst     # dirs before files — easier to parse structure
--noreport      # suppress summary line — saves tokens
--gitignore     # respect .gitignore — auto-excludes build artifacts, deps, etc.
```

For non-git directories or to exclude additional noise:

```
-I "node_modules|.git|__pycache__|.venv|venv|.tox|.mypy_cache|.pytest_cache|.cache|.ruff_cache"
```

---

## Compact Flag Reference

| Flag | Purpose | When to Use |
|------|---------|-------------|
| `-d` | Directories only | Skeleton scan — first pass of scan recipe |
| `-L N` | Max depth N | Control recursion — start shallow (2), go deeper (3-4) |
| `-f` | Print full path prefix | find recipe — need paths for later read calls |
| `-P "pat"` | Only show matching files | find recipe — filter to specific names/extensions |
| `--prune` | Remove empty dirs from filtered output | Always pair with `-P` |
| `--filelimit=N` | Skip dirs with >N entries | Spot bloated dirs: 80 for wide scans, 50 for deep dives |

> Full flag reference: `references/tree-manual.md`

---

## Patterns

Common intent-to-recipe mappings:

**New repo / unfamiliar codebase:**
→ `scan` (skeleton overview) + `deep` into the source directory
Goal: Build a mental map — language, framework, major subsystems.

**Find code for a specific feature or topic:**
→ `find` with topic synonyms + `deep` into matching directories
Goal: Locate specific files to read. Pattern example: `"*auth*|*login*|*session*"`.

**Plan where to add new code or docs:**
→ `scan` (full layout) + `deep` into source dir AND docs/planning dir
Goal: Understand conventions — where do tests, configs, docs, and scripts live?

**Investigate a bug or behavior:**
→ `find` with error keywords or module names + `deep` into matches
Goal: Narrow down to the 3-5 files most likely involved.

---

## Troubleshooting

If `tree` is not installed, inform the user and suggest installation:
`apt install tree` (Debian/Ubuntu) · `brew install tree` (macOS) · `dnf install tree` (RHEL)
