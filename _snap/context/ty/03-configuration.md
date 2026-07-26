# ty Configuration Guide

**Source:** https://docs.astral.sh/ty/configuration/

## Configuration File Locations

ty searches for configuration files in this order:
- Current directory or nearest parent directory
- User-level configuration at `~/.config/ty/ty.toml` (macOS/Linux) or `%APPDATA%\ty\ty.toml` (Windows)

## Supported File Formats

### pyproject.toml

Uses the `[tool.ty]` table prefix:

```toml
[tool.ty.rules]
index-out-of-bounds = "ignore"
```

### ty.toml

Identical structure without the `[tool.ty]` prefix:

```toml
[rules]
index-out-of-bounds = "ignore"
```

## Precedence Rules

1. **ty.toml takes priority over pyproject.toml** — "if both `ty.toml` and `pyproject.toml` files are present in a directory, configuration will be read from `ty.toml`"
2. **Project-level overrides user-level** — "project-level configuration taking precedence over the user-level configuration"
3. **Command-line arguments override all** — "Settings provided via command line take precedence over persistent configuration"

## Configuration Merging

When both project and user-level configs exist:
- Scalar values (strings, numbers, booleans) use the project-level setting
- Arrays merge together with project-level settings appearing last

For complete configuration options, refer to the configuration reference documentation.
