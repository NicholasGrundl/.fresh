# ty CLI Reference

**Source:** https://docs.astral.sh/ty/reference/cli/

## Main Command

**ty** - "An extremely fast Python type checker."

Usage: `ty <COMMAND>`

---

## Commands

### ty check

Check a project for type errors

**Usage:** `ty check [OPTIONS] [PATH]...`

**Arguments:**
- `PATHS`: Files or directories to check (defaults to project root)

**Key Options:**
- `--color <when>`: Control colored output (`auto`, `always`, `never`)
- `--config-file <path>`: Specify `ty.toml` configuration file
- `--python <path>` / `--venv <path>`: Point to Python environment
- `--python-version <version>`: Target Python version (3.7-3.14)
- `--output-format <format>`: Choose output style (`full`, `concise`, `gitlab`, `github`)
- `--watch` / `-W`: Monitor files for changes
- `--exclude <pattern>`: Gitignore-style exclusion patterns
- `--error <rule>`: Treat rule as error
- `--warn <rule>`: Treat rule as warning
- `--ignore <rule>`: Disable specific rule
- `--error-on-warning`: Exit with code 1 on warnings
- `--exit-zero`: Always exit with code 0

### ty server

Start the language server

**Usage:** `ty server`

### ty version

Display ty's version

**Usage:** `ty version`

### ty generate-shell-completion

Generate shell completion

**Usage:** `ty generate-shell-completion <SHELL>`

### ty help

Print help message or subcommand help

**Usage:** `ty help [COMMAND]`
