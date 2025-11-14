# Development Setup Guide

This guide covers setting up your development environment for this Python + Node.js project.

## Prerequisites by Operating System

### Windows (PowerShell or Command Prompt)

#### 1. Install WSL2 (Recommended)
```powershell
wsl --install
```
Then follow the **Linux (Ubuntu/WSL2)** section below.

#### 2. Alternative: Native Windows Setup

**Install Python:**
- Download from [python.org](https://www.python.org/downloads/)
- Check "Add Python to PATH" during installation

**Install Node.js:**
- Download from [nodejs.org](https://nodejs.org/)
- This includes npm

**Install uv:**
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Install nvm-windows:**
- Download installer from [github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows/releases)
- Run installer

**Note:** direnv is not officially supported on Windows. Consider using WSL2 instead, or manually activate environments.

---

### Linux (Ubuntu/WSL2)

#### 1. Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Install Build Dependencies
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

#### 3. Install uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add to PATH (if not automatically added):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify installation:
```bash
uv --version
```

#### 4. Install nvm
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

Reload your shell:
```bash
source ~/.bashrc
```

Verify installation:
```bash
nvm --version
```

#### 5. Install direnv
```bash
sudo apt install direnv
```

Add to your shell (add to `~/.bashrc`):
```bash
eval "$(direnv hook bash)"
```

Reload your shell:
```bash
source ~/.bashrc
```

Verify installation:
```bash
direnv --version
```

---

### macOS (Bash or Zsh)

#### 1. Install Homebrew (if not installed)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. Install Build Tools
```bash
xcode-select --install
```

#### 3. Install uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add to PATH (if not automatically added):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # or ~/.bash_profile
source ~/.zshrc  # or source ~/.bash_profile
```

Verify installation:
```bash
uv --version
```

#### 4. Install nvm
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

Reload your shell:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

Verify installation:
```bash
nvm --version
```

#### 5. Install direnv
```bash
brew install direnv
```

Add to your shell config (`~/.zshrc` or `~/.bash_profile`):
```bash
eval "$(direnv hook bash)"  # or "$(direnv hook zsh)" for zsh
```

Reload your shell:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

Verify installation:
```bash
direnv --version
```

---

## Project Setup

### 1. Clone the repository
```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Set up Python environment
```bash
# Create virtual environment
uv venv

# Activate it (or let direnv do this automatically)
source .venv/bin/activate

# Install Python dependencies
uv pip install -r requirements.txt
```

### 3. Set up Node environment
```bash
# Install the Node version specified in .nvmrc
nvm install

# Use the correct Node version (or let direnv do this automatically)
nvm use

# Install Node dependencies
npm install
```

### 4. Configure environment variables
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your local configuration
nano .env  # or use your preferred editor
```

### 5. Allow direnv (first time only)
```bash
direnv allow
```

Now whenever you `cd` into this directory:
- Python virtual environment activates automatically
- Node version switches automatically
- Environment variables load automatically

---

## Verification

### Check Python setup:
```bash
python --version
which python  # Should point to .venv/bin/python
```

### Check Node setup:
```bash
node --version
npm --version
```

### Check environment variables:
```bash
echo $DATABASE_URL  # Should show your configured value
```

---

## Daily Development Workflow

```bash
# Navigate to project
cd <project-directory>

# direnv automatically activates everything

# Start development
npm run dev          # or whatever your start command is
python main.py       # or whatever your Python entry point is
```

---

## Troubleshooting

### direnv not activating
```bash
# Make sure it's hooked into your shell
direnv hook bash  # Should output eval code

# Re-allow the directory
direnv allow
```

### Python virtual environment not found
```bash
# Recreate it
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

### Node version mismatch
```bash
# Reinstall the correct version
nvm install
nvm use
```

### Environment variables not loading
```bash
# Make sure .env file exists
ls -la .env

# Check .envrc has dotenv line
cat .envrc | grep dotenv
```