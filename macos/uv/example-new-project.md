# Example: Starting a New Python Project with UV

This guide walks through creating a new Python project from scratch using UV and the `.fresh` repository templates.

## Scenario

You want to create a new data analysis project called `sales-analysis` that uses pandas, matplotlib, and jupyter.

## Step-by-Step

### 1. Create Project Directory

```bash
mkdir ~/projects/sales-analysis
cd ~/projects/sales-analysis
```

### 2. Copy Template Files

```bash
# Copy the Python project template files
cp ~/.fresh/python/pyproject.toml .
cp ~/.fresh/python/Makefile .
cp ~/.fresh/python/.gitignore .
```

### 3. Customize pyproject.toml

Edit `pyproject.toml` to match your project:

```toml
[project]
name = "sales-analysis"
version = "0.1.0"
description = "Sales data analysis and visualization"
authors = [{name = "Your Name", email = "your.email@example.com"}]
requires-python = ">=3.11"
dependencies = [
    "pandas>=2.0.0",
    "matplotlib>=3.7.0",
    "jupyter>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "ruff>=0.1.0",
    "ipython>=8.0.0",
]
```

### 4. Create Virtual Environment with UV

```bash
# Create the virtual environment
uv venv

# Activate it
source .venv/bin/activate
```

### 5. Install Dependencies

```bash
# Install project dependencies
uv pip install -e .

# Install dev dependencies
uv pip install -e ".[dev]"
```

### 6. Generate Requirements Files (Optional)

For reproducibility, create locked requirements files:

```bash
# Generate requirements.txt
uv pip compile pyproject.toml -o requirements.txt

# Generate dev requirements
uv pip compile pyproject.toml --extra dev -o requirements-dev.txt
```

### 7. Create Project Structure

```bash
# Create basic Python package structure
mkdir -p sales_analysis tests notebooks data

# Create __init__.py files
touch sales_analysis/__init__.py
touch tests/__init__.py

# Create initial files
touch sales_analysis/loader.py
touch sales_analysis/analyzer.py
touch tests/test_loader.py
touch notebooks/01_exploratory_analysis.ipynb
```

### 8. Initialize Git

```bash
git init
git add .
git commit -m "Initial commit: Project setup with UV"
```

## Project Structure

After setup, your project should look like:

```
sales-analysis/
├── .venv/                      # Virtual environment (not committed)
├── .gitignore                  # From template
├── pyproject.toml              # Project configuration
├── Makefile                    # Build commands
├── requirements.txt            # Locked dependencies
├── requirements-dev.txt        # Locked dev dependencies
├── sales_analysis/             # Main package
│   ├── __init__.py
│   ├── loader.py
│   └── analyzer.py
├── tests/                      # Test suite
│   ├── __init__.py
│   └── test_loader.py
├── notebooks/                  # Jupyter notebooks
│   └── 01_exploratory_analysis.ipynb
└── data/                       # Data files (not committed)
```

## Daily Development Workflow

### Starting Work

```bash
cd ~/projects/sales-analysis
source .venv/bin/activate
```

### Adding a New Dependency

```bash
# Add to project
uv add seaborn

# Or manually add to pyproject.toml and reinstall
uv pip install -e .
```

### Running Tests

```bash
# Using pytest directly
pytest

# Or using Make (if configured)
make test
```

### Running Linter

```bash
# Run Ruff
ruff check .

# Auto-fix issues
ruff check --fix .
```

### Starting Jupyter

```bash
jupyter notebook
# or
jupyter lab
```

## Alternative: Using UV's Built-in Project Management

UV also has project management commands (newer feature):

```bash
# Initialize project with UV
uv init sales-analysis
cd sales-analysis

# Add dependencies
uv add pandas matplotlib jupyter

# Add dev dependencies
uv add --dev pytest ruff ipython

# Run commands in the project environment
uv run python script.py
uv run pytest
uv run jupyter notebook
```

## Next Steps

1. **Configure Ruff**: Edit `pyproject.toml` linting rules
2. **Set up CI/CD**: Add GitHub Actions or similar
3. **Add pre-commit hooks**: Automate linting and testing
4. **Write documentation**: Add README.md with project details
5. **Share requirements**: Commit `requirements*.txt` for reproducibility

## Tips

- **Keep dependencies minimal**: Only add what you actually use
- **Use version pins**: For reproducibility (UV handles this automatically)
- **Document environment**: Update README with setup instructions
- **Regular updates**: Periodically update dependencies with `uv pip install --upgrade`