# Development Setup Guide

This guide covers setting up your PC for Python + Node.js development.

## Prerequisites by Operating System

### Windows (PowerShell or Command Prompt)

#### Native Windows Setup

**Install UV:**

see https://docs.astral.sh/uv/getting-started/installation/#installation-methods

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Install nvm-windows:**
- Download installer from [github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows/releases)
- Run installer

**Note:** direnv is not officially supported on Windows. Consider using WSL2 instead, or manually activate environments.

---

### Linux (Ubuntu/WSL2)

#### 1. System Packages

Update and install any OS level packages

```bash
sudo apt update && sudo apt upgrade -y

**Build Dependencies**
```bash
sudo apt install -y \
  build-essential \
  curl \
  git \
  libssl-dev \
  libffi-dev \
  python3-dev \
  libpq-dev \
  zlib1g-dev
```

#### 2. Install uv

Install UV at the global OS level to manage python packages

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add to PATH (if not automatically added):
- For `.bashrc` add: `export PATH="$HOME/.local/bin:$PATH`
- Often `~/.local/bin` is already sourced so this may be unecessary

Verify installation:
```bash
uv --version
```

#### 3. Install nvm

Install NVM at the OS level to manage all node dependencies

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

Verify installation:
```bash
source ~/.bashrc
nvm --version
```

#### 4. Install direnv

We will use `direnv` to manage env vars as well as auto sourcing our python and node envs per project

```bash
sudo apt install direnv
```

Add to your shell (add to `~/.bashrc`):
- `eval "$(direnv hook bash)`

Verify installation:
```bash
source ~/.bashrc
direnv --version
```

#### 5. Install Just

We will use Just to manage all project level commands and aliased scripts
- https://github.com/casey/just

```bash
sudo apt install just
```

Alternatively we can install the binaries (similiar to UV)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
```

Verify installation:
```bash
source ~/.bashrc
just --help
```



---

### macOS (Bash)

#### 1. Install Homebrew (if not installed)

We will manage our packages with brew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Install Build Tools
```bash
xcode-select --install
```

#### 3. Install uv
Install UV at the global OS level to manage python packages

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add to PATH (if not automatically added):
- For `.bashrc` add: `export PATH="$HOME/.local/bin:$PATH`
- Often `~/.local/bin` is already sourced so this may be unecessary

Verify installation:
```bash
uv --version
```

#### 4. Install nvm

Install NVM at the OS level to manage all node dependencies

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

Verify installation:
```bash
source ~/.bashrc
nvm --version
```

#### 5. Install direnv

We will use `direnv` to manage env vars as well as auto sourcing our python and node envs per project

```bash
brew install direnv
```

Add to your shell (add to `~/.bashrc`):
- `eval "$(direnv hook bash)`

Verify installation:
```bash
source ~/.bashrc
direnv --version
```


#### 5. Install Just

We will use Just to manage all project level commands and aliased scripts
- https://github.com/casey/just


Alternatively we can install the binaries (similiar to UV)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/.local/bin
```

Verify installation:
```bash
source ~/.bashrc
just --help
```


---

## Project Setup

### 1. Clone the repository
```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Set up Python environment

Create a new project
```bash
# Create virtual environment
uv init

# Add or remove packages
uv add [package]
uv remove [package]

# sync environment apckages with pyproject.toml
uv sync
```

### 3. Set up Node environment

Create a `.nvmrc` file with the node version
```bash
echo "20" > .nvmrc

# or copy the file
cp .nvmrc.example .nvmrc
```

```bash
# Install the Node version specified in .nvmrc
nvm install

# Install Node dependencies
npm install
```

### 4. Configure environment variables

Copy the `.envrc` to auto activate node and python venv

```bash
cp .envrc.example .envrc
```

Copy the evn file and update the env vars as desired

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your local configuration
nano .env  # or use your preferred editor
```


### 5. Allow direnv (first time only)

Enable direnv on the project so it auto activates and has the env vars

```bash
direnv allow
```

Now whenever you `cd` into this directory:
- Python virtual environment activates automatically
- Node version switches automatically
- Environment variables load automatically


## Ad Hoc Development

For adhock development and exploratory work we use the following approaches:
- miniconda envs with python packages installed (existing approach, heavier weight)
- uv tools (globally available packages) to run marimo notebooks

### UV Tools

Install marimo as a uv tool
```bash
uv tool install marimo
```

Create a custom bash function to generate a new marimo tempalted notebook

```bash
explore() {
    # Check if marimo is installed
    if ! command -v marimo &> /dev/null; then
        echo "marimo is not installed."
        echo "Install it with: uv tool install marimo"
        return 1
    fi
    
    # Determine filename with increment if needed
    local base_filename="${1:-explore}"
    local filename="${base_filename}.py"
    local counter=1
    
    while [ -f "$filename" ]; do
        filename="${base_filename}_${counter}.py"
        ((counter++))
    done
    
    # Create the templated marimo notebook
    cat > "$filename" << 'EOF'
# /// script
# dependencies = [
#   "pandas",
#   "matplotlib",
#   "numpy",
# ]
# ///

import marimo

__generated_with = "0.9.14"
app = marimo.App()


@app.cell
def __():
    import marimo as mo
    import pandas as pd
    import matplotlib.pyplot as plt
    import numpy as np
    return mo, np, pd, plt

@app.cell
def __():
    # Your code here
    return


if __name__ == "__main__":
    app.run()
EOF
    
    echo "Created $filename"
    echo "Run with: marimo edit $filename"
}
```

Then from any location we can run the following:
- `explore [optional notebookname]` will create a new blank notebook
- `marimo edit [notebook name]` will run the notebook and install any inline dependencies