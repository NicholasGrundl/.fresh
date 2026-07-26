# ty Documentation Collection

This directory contains documentation for **ty**, Astral's extremely fast Python type checker written in Rust.

## Status

**Important:** ty is in preview and not ready for production use. Expect bugs, missing features, and potential errors.

## Documentation Files

1. **01-overview.md** - Main documentation overview and getting started guide
2. **02-github-readme.md** - GitHub repository README with project status and resources
3. **03-configuration.md** - Configuration file locations, formats, and precedence rules
4. **04-cli-reference.md** - Complete CLI command reference with all options
5. **05-editors.md** - Editor integration guides (VS Code, Neovim, Zed, PyCharm)
6. **06-configuration-reference.md** - Detailed configuration options reference
7. **07-environment-variables.md** - Environment variables reference (ty-specific and external)

## Quick Start

```bash
# Run ty on current directory
uvx ty check

# Run on specific file
uvx ty check example.py

# With virtual environment
uvx ty check --python .venv/bin/python

# Watch mode
uvx ty check --watch
```

## Official Links

- **Documentation:** https://docs.astral.sh/ty/
- **GitHub:** https://github.com/astral-sh/ty
- **Playground:** https://play.ty.dev

## Key Features

- Extremely fast type checking (written in Rust)
- Language server support for editor integration
- Automatic virtual environment detection
- Configurable via pyproject.toml or ty.toml
- Multiple output formats (full, concise, GitHub, GitLab)
- Watch mode for continuous checking

## Configuration

ty searches for configuration in:
1. Project-level: `ty.toml` or `pyproject.toml` (in `[tool.ty]` table)
2. User-level: `~/.config/ty/ty.toml` (macOS/Linux) or `%APPDATA%\ty\ty.toml` (Windows)

Priority: CLI args > ty.toml > pyproject.toml > user-level config
