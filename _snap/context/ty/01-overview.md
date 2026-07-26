# ty Documentation - Overview

**Source:** https://docs.astral.sh/ty/

## Overview

**ty** is described as "An extremely fast Python type checker, written in Rust." It's maintained by Astral and available through multiple installation methods.

## Getting Started

The quickest way to try ty is through the online playground or using uvx:
- Run `uvx ty` to execute the tool
- Use `uvx ty check` to run the type checker
- Specify files directly: `uvx ty check example.py`

## Key Features

The tool automatically:
- Scans Python files in the working directory and subdirectories
- Detects virtual environments (via `VIRTUAL_ENV` or `.venv` in project root)
- Discovers installed packages in the active environment
- Runs from project root when `pyproject.toml` is present

## Documentation Structure

The documentation includes sections on:
- **Concepts**: Installation, configuration, module discovery, Python versions, file exclusions, rules, suppression, and editor support
- **Reference**: Configuration details, rule specifications, CLI options, exit codes, environment variables, and editor settings

## Installation

Alternative installation methods are documented separately, with uvx being the recommended quick-start approach.

## Note for New Users

When encountering cascading errors with `venv` module environments, adding the venv directory to `.gitignore` or `.ignore` files before retrying may help resolve issues.
