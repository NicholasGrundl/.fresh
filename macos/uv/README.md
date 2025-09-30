# UV - Modern Python Package Management

UV is an extremely fast Python package installer and resolver, written in Rust. It's a drop-in replacement for pip and pip-tools, but significantly faster and more reliable.

## Why UV?

- **Speed**: 10-100x faster than pip
- **Reliable**: Better dependency resolution
- **Modern**: Built with modern Python workflows in mind
- **Compatible**: Works with existing requirements.txt and pyproject.toml
- **Simple**: Easy to use, familiar commands

## Installation

### Install via Homebrew

```bash
brew install uv
```

### Verify Installation

```bash
uv --version
```

## Basic Usage

### Creating a New Python Project

```bash
# Create a new project directory
mkdir my-project
cd my-project

# Initialize a new Python project (creates pyproject.toml)
uv init

# Create a virtual environment
uv venv

# Activate the virtual environment
source .venv/bin/activate
```

### Installing Packages

```bash
# Install a package
uv pip install requests

# Install from requirements.txt
uv pip install -r requirements.txt

# Install dev dependencies
uv pip install -r requirements-dev.txt
```

### Managing Dependencies

```bash
# Compile requirements (like pip-compile)
uv pip compile pyproject.toml -o requirements.txt

# Sync environment with requirements (like pip-sync)
uv pip sync requirements.txt

# Install package and add to pyproject.toml
uv add requests

# Remove package
uv remove requests
```

## Project Workflow

### Quick Start for a New Project

```bash
# 1. Create project directory
mkdir my-new-project && cd my-new-project

# 2. Initialize with uv
uv init

# 3. Create virtual environment
uv venv

# 4. Activate environment
source .venv/bin/activate

# 5. Add your dependencies
uv add numpy pandas matplotlib

# 6. Start coding!
```

### Using with Existing Python Templates

The `.fresh` repository includes Python project templates in `../../python/`. Use UV with them:

```bash
# Copy template files
cp ../../python/pyproject.toml .
cp ../../python/Makefile .
cp ../../python/requirements*.txt .

# Create virtual environment
uv venv

# Activate
source .venv/bin/activate

# Install dependencies
uv pip sync requirements.txt
uv pip sync requirements-dev.txt
```

## Integration with Python Templates

### pyproject.toml Integration

UV works seamlessly with the pyproject.toml template from `../../python/`:

```bash
# Install project in editable mode
uv pip install -e .

# Install with dev dependencies
uv pip install -e ".[dev]"
```

### Makefile Commands

The Python Makefile template can be adapted to use UV:

```makefile
# Replace pip commands with uv equivalents
install:
	uv pip sync requirements.txt

install-dev:
	uv pip sync requirements-dev.txt

compile:
	uv pip compile pyproject.toml -o requirements.txt
```

## Common Commands Comparison

| Task | pip | uv |
|------|-----|-----|
| Install package | `pip install requests` | `uv pip install requests` |
| Install from file | `pip install -r requirements.txt` | `uv pip install -r requirements.txt` |
| Compile requirements | `pip-compile` | `uv pip compile` |
| Sync environment | `pip-sync` | `uv pip sync` |
| Create venv | `python -m venv .venv` | `uv venv` |
| List packages | `pip list` | `uv pip list` |
| Show package | `pip show requests` | `uv pip show requests` |

## Advanced Features

### Multiple Python Versions

```bash
# Use specific Python version
uv venv --python 3.11

# Use system Python
uv venv --python python3.12
```

### Lock Files

```bash
# Generate a lock file (like Poetry)
uv lock

# Install from lock file
uv sync
```

### Workspace Support

UV supports monorepo/workspace setups similar to Cargo or npm workspaces.

## Tips and Best Practices

1. **Always use virtual environments**: `uv venv` before installing packages
2. **Use `uv pip sync`**: Ensures environment matches requirements exactly
3. **Compile dependencies**: Use `uv pip compile` to generate locked requirements
4. **Cache management**: UV automatically caches packages for faster installs
5. **Compatible with pip**: Can mix UV and pip commands if needed

## Troubleshooting

### UV not found after installation
```bash
# Reload shell
source ~/.bash_profile

# Or check PATH
which uv
```

### Virtual environment not activating
```bash
# Make sure you're using source (not just running the script)
source .venv/bin/activate

# Check if venv was created
ls -la .venv/
```

### Dependency resolution issues
```bash
# Clear UV cache
uv cache clean

# Try with verbose output
uv pip install -v package-name
```

## Migration from pip

### From requirements.txt
```bash
# No changes needed! Just replace pip with uv
uv pip install -r requirements.txt
```

### From Poetry
```bash
# Export Poetry dependencies
poetry export -f requirements.txt -o requirements.txt

# Install with UV
uv pip install -r requirements.txt
```

### From Conda
```bash
# Export conda environment (packages only)
conda list -e > conda-requirements.txt

# Convert to pip format and install
# (may need manual conversion for conda-specific packages)
```

## See Also

- [Official UV Documentation](https://github.com/astral-sh/uv)
- [Python Templates](../../python/) - Existing Python project templates
- [NVM Setup](../nvm/) - Node.js equivalent for JavaScript projects