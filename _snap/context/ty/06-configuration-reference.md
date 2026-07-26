# ty Configuration Reference

**Source:** https://docs.astral.sh/ty/reference/configuration/

## Top-Level Configuration Sections

**rules** — Configures enabled rules and their severity levels (ignore, warn, error).

**environment** — Settings for Python environment detection and module resolution.

**overrides** — File-specific rule configurations using glob patterns.

**src** — Source file inclusion/exclusion patterns and discovery settings.

**terminal** — Output formatting and exit behavior options.

---

## environment Options

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `extra-paths` | `list[str]` | `[]` | "User-provided paths that should take first priority in module resolution" |
| `python` | `str` | `null` | Path to Python environment or interpreter for resolving imports |
| `python-platform` | `str` | Current platform | Target platform (win32, darwin, linux, android, ios, all) |
| `python-version` | `str` | `"3.14"` | Python version in M.m format for feature compatibility checks |
| `root` | `list[str]` | Auto-detected | "Root paths of the project, used for finding first-party modules" |
| `typeshed` | `str` | `null` | Custom typeshed directory path for stdlib type stubs |

---

## src Options

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `include` | `list[str]` | `null` | Files/directories to type check using gitignore-like syntax |
| `exclude` | `list[str]` | `null` | Files/directories to skip, with negation patterns supported |
| `respect-ignore-files` | `bool` | `true` | Whether to honor .gitignore and similar files |
| `root` | `str` | Auto-detected | *Deprecated* — use `environment.root` instead |

---

## terminal Options

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `error-on-warning` | `bool` | `false` | "Use exit code 1 if there are any warning-level diagnostics" |
| `output-format` | `str` | `full` | Diagnostic output format: full or concise |

---

## overrides Structure

Overrides apply "different rule configurations to specific files or directories" with later entries taking precedence over earlier ones.

**Components:**
- `include` — Matching file patterns
- `exclude` — Patterns to exclude within matched files
- `rules` — Rule severity overrides for matched files
