# ty: Python Type Checker - GitHub README

**Source:** https://github.com/astral-sh/ty

## Overview

**ty** is a high-performance Python type checker and language server implemented in Rust. The project is maintained by Astral and serves as an extremely fast alternative for static type analysis.

## Key Information

### Status & Warning

The project explicitly states: "ty is in preview and is not ready for production use." Users should anticipate encountering bugs, missing features, and potential fatal errors during this preview phase.

### Getting Started

The quickest way to try ty is through `uvx`:
```bash
uvx ty
```

For type checking operations, use the check command:
```bash
uvx ty check
```

You can target specific files:
```bash
uvx ty check example.py
```

### Important Notes on Module Discovery

When performing type checks, ty automatically locates packages in:
- Active virtual environments (via `VIRTUAL_ENV` variable)
- A `.venv` directory in the project root or working directory

For packages in non-virtual environments, users must specify the target path using the `--python` flag. The documentation provides detailed guidance on module discovery configuration.

### Resources

- **Online Playground**: Available at play.ty.dev for immediate experimentation
- **Documentation**: Comprehensive docs available at docs.astral.sh/ty/
- **CLI Reference**: Detailed command-line options documented separately

### Community & Development

- Bug reports and questions should be filed as GitHub issues
- The Rust source code development occurs in the separate Ruff repository
- Pull requests for Rust components should be opened against the Ruff project

### Licensing

ty is distributed under the MIT license, allowing broad usage with proper attribution.
