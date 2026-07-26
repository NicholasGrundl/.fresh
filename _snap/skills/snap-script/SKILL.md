---
name: snap-script
description: "Author PEP 723 single-file Python scripts that run with `uv run` as lightweight CLI tools for AI agents. Use this skill whenever the user wants a standalone Python script, a small CLI tool, a data-transformation or plotting script, or asks to 'write a uv script' / 'make a script with inline deps'. The skill follows a gather-then-write workflow: it reads any brief or sample data, resolves a fixed checklist of fields, asks only for genuine gaps, previews the CLI signature, then writes a self-contained script using typer (CLI + --help), loguru (logging to stdout), pathlib (paths), and nanoid (non-clobbering output names). It encodes conventions for CLI surface, sensible defaults, I/O layout, and matplotlib/seaborn plotting. Offer this skill when the user mentions PEP 723, uv run, inline script metadata, or wants a script that an agent can invoke as a CLI tool."
metadata:
  author: nicholasgrundl
  version: "0.1"
compatibility: Requires `uv` installed and on PATH. Generated scripts fetch their own inline dependencies at run time.
---

# snap-script

Write **PEP 723 single-file Python scripts** that run with `uv run`. The scripts are
lightweight CLI tools, primarily invoked by AI agents inside a project directory, with
humans as a secondary audience.

**The artifact is the script.** It is self-contained, version-controllable, and editable by
hand. Each script declares its own dependencies in a `# /// script` block, so `uv run` fetches
them automatically — no virtualenv, no `pip install`.

This is the *foundation* skill: it produces a correct, convention-following CLI scaffold for
any domain. Domain specifics (the actual pandas cleanup, the actual plot) are supplied by the
user's prompt or by composing skills on top of this one.

## Design principles (why the scaffold looks the way it does)

1. **Optimize for agent usage, not install size.** Inline deps are cheap. Pull in `typer`
   for free, excellent `--help` rather than hand-rolling `argparse`.
2. **Concise CLI surface, expansive `--help`.** Expose only the handful of args an agent
   needs to vary (input, output, a few knobs). Everything else is a sensible default. Every
   flag must show up clearly in `--help` so an agent can introspect without reading source.
3. **Defaults assume `uv run` from a project root.** Input/output paths follow a conventional
   project layout (see I/O conventions).
4. **Pathlib everywhere.** All paths and file ops use `pathlib.Path`. No `os.path.join`, no
   string concatenation.
5. **Live feedback via stdout.** Logging is for the human watching the agent. All progress
   goes to stdout (via loguru) so it surfaces inline in the agent's tool output.

## Preferred packages

| Concern | Package | Why |
| --- | --- | --- |
| CLI | `typer` | Type-hint-driven, auto-generates excellent `--help`. Minimal boilerplate. |
| Paths | `pathlib` (stdlib) | Cross-OS, no extra dep. |
| Logging | `loguru` | One-line setup, no handler ceremony. Configured to write to stdout. |
| Output naming | `nanoid` | Short random suffix to avoid clobbering existing outputs. |
| Data (domain) | `pandas` | For CSV/Excel cleanup scripts. |
| Plotting (domain) | `matplotlib` / `seaborn` | For figure scripts. See `references/plotting-patterns.md`. |

## The workflow you (the LLM) follow

Be **fast when the user has specified everything; chatty only for genuine gaps.**

### Phase 0 — Detect inputs

- If the invocation references a brief/spec file (a markdown file in `_blueprint/features/`,
  or an explicit `@path/to/spec.md`), read it first.
- If a sample data file is referenced (CSV, Excel), peek at its headers and dtypes to inform
  later decisions.
- If neither is present, proceed with an empty context.

### Phase 1 — Resolve the checklist (silently)

Fill these in from the brief / sample data / the user's prompt. Do **not** ask about anything
already answered or reasonably inferable.

- **Purpose** — one-line description of what the script does.
- **Filename** — a slug derived from purpose (e.g. `clean_excel_export.py`).
- **Inputs** — path argument(s), expected file type, and known column shape if a sample was peeked.
- **Outputs** — path(s), file type, and which directory convention applies.
- **CLI flags** — which transformation knobs (beyond input/output/clobber/verbose) to expose.
  Default to none unless the brief calls them out.
- **Domain deps** — pandas? matplotlib? seaborn? Derive from purpose; do not ask.
- **Verbose flag** — default yes (`--verbose / -v` bumps loguru to DEBUG).

### Phase 2 — Ask only what's still missing

Use at most **1–3 targeted questions**. If Phase 0–1 resolved everything, skip this phase.
Typical gaps worth a question:

- Ambiguous output convention (several plausible target directories).
- Unclear which columns are id_vars vs value_vars for a melt.
- Whether a specific knob should be a CLI flag or hardcoded.

### Phase 3 — Preview signature, confirm, then write

1. Surface the proposed CLI signature as a `--help`-style preview: positional args, flags with
   defaults, one-line description. One round of "looks good / change X" beats a full rewrite.
2. Once confirmed, copy `assets/script_template.py` and adapt it: set the dependency list, the
   docstring + example invocation, the arguments, and fill in the work between the
   `--- do the work here ---` markers.
3. Write the script to the project's `scripts/` directory (or wherever the user indicates).
4. **Run it with `--help`** (`uv run <script> --help`) to verify it parses and the help text
   reads well. If the user gave a sample input, optionally run it for real.
5. Report the script path and the run command. If it failed, surface the error verbatim and
   the likely cause — don't silently patch; ask before fixing.

## Conventions the generated script must follow

### PEP 723 block

```python
# /// script
# requires-python = ">=3.11"
# dependencies = [ "typer", "loguru", "nanoid", ...domain deps ]
# ///
```

`requires-python` floors at 3.11 so modern typing works without compatibility shims. For the
full spec, see `references/pep723.md` (load only if you hit an edge case).

### CLI + logging scaffold

Use `assets/script_template.py` verbatim as the starting point. It already wires up:

- `typer.Typer(add_completion=False, ...)` — drops shell-completion noise from `--help`.
- `configure_logging(verbose)` — loguru to stdout, INFO by default, DEBUG with `--verbose`.
- The module docstring as human-readable purpose + example invocation.

### I/O conventions

Default project layout:

```text
project/
├── data/       # inputs and processed outputs
├── figures/    # plot outputs
└── scripts/    # the PEP 723 scripts themselves
```

- **Input path**: required positional argument, no default — fail fast if missing.
- **Output path**: optional `--output / -o`. If omitted, derive from the input path.
- **Overwrite**: do **not** clobber by default. `resolve_output_path()` in the template inserts
  a short random nanoid before the extension (`report.csv` → `report_a3k9zd.csv`) when the
  target exists. Random, not deterministic, so re-runs always produce a new file. The script
  **must** log the final resolved path as a single INFO line at the end. `--clobber` opts into
  overwriting.
- **Exit codes**: 0 on success, non-zero on error (`raise typer.Exit(code=1)`).

### Plotting (when applicable)

If the script produces figures, read `references/plotting-patterns.md` for the
matplotlib/seaborn `fig, ax` + `plt.close()` + `fig.savefig()` conventions. Never `plt.show()`.

## Bundled files

- `assets/script_template.py` — the canonical scaffold to copy and adapt. Start here every time.
- `references/plotting-patterns.md` — matplotlib/seaborn conventions; load on demand.
- `references/pep723.md` — full PEP 723 spec; load only for edge cases.

## A note on skill location

This skill may be installed under `.claude/skills/` (Claude) or `.agents/skills/`
(Antigravity and other open-source agents). Reference bundled files by their path **relative to
this SKILL.md** (e.g. `assets/script_template.py`) so the skill works regardless of which root
it lives under. Generated scripts live in the *project's* `scripts/` directory, not inside the
skill.

## What this skill does NOT do

- It does not implement domain logic for you. The pandas cleanup pipeline and the specific plots
  are driven by the user's prompt or a composing skill — this skill guarantees the scaffold,
  conventions, and CLI ergonomics.
- It does not manage a project virtualenv or `pyproject.toml`; everything rides on PEP 723 inline
  deps and `uv run`.
