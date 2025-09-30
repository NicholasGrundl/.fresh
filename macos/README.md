# macOS Development Environment Setup

Complete guide for setting up a modern development environment on macOS using the `.fresh` repository templates and tools.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Components](#components)
  - [Bash Configuration](#bash-configuration)
  - [Starship Prompt](#starship-prompt)
  - [UV (Python)](#uv-python)
  - [NVM (Node.js)](#nvm-nodejs)
  - [VSCode](#vscode)
- [Setup Checklist](#setup-checklist)
- [Platform Notes](#platform-notes)
- [Additional Resources](#additional-resources)

---

## Prerequisites

### 1. Install Xcode Command Line Tools

Required for compiling software and using git:

```bash
xcode-select --install
```

### 2. Install Homebrew

The package manager for macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Important**: Follow the post-install instructions to add Homebrew to your PATH.

For Apple Silicon (M1/M2/M3):
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
```

For Intel Macs:
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
```

Reload your shell:
```bash
source ~/.bash_profile
```

### 3. Verify Installation

```bash
brew --version
git --version
```

---

## Quick Start

Complete setup in ~15 minutes:

```bash
# 1. Install modern bash
brew install bash bash-completion@2

# 2. Install development tools
brew install starship uv nvm direnv git bat

# 3. Install Nerd Font for terminal icons
brew install --cask font-fira-code-nerd-font

# 4. Set up bash configuration
cd ~/.fresh/macos/bash
cp .bashrc ~/.bashrc
cp .bash_profile ~/.bash_profile
cp .bash_custom_functions ~/.bash_custom_functions

# 5. Set up Starship prompt
mkdir -p ~/.config
cp ~/.fresh/macos/starship/starship-traditional.toml ~/.config/starship.toml

# 6. Reload shell
source ~/.bash_profile

# 7. Install Node.js LTS
nvm install --lts
nvm use --lts
nvm alias default lts/*
```

**Done!** You now have a modern development environment.

---

## Components

### Bash Configuration

Modern bash setup with custom prompt, functions, and tool integrations.

**Location**: `bash/`

**What's included**:
- `.bashrc` - Main configuration (macOS-optimized)
- `.bash_profile` - Login shell configuration
- `.bash_custom_functions` - SSH and environment management utilities

**Key features**:
- Custom colored prompt with git branch display
- SSH agent persistence
- Environment variable management (.env file support)
- Direnv integration
- NVM integration
- Homebrew configuration (Apple Silicon & Intel)

**See**: [bash/README.md](bash/README.md) for detailed setup and customization.

---

### Starship Prompt

Modern, fast, customizable shell prompt written in Rust.

**Location**: `starship/`

**What's included**:
- `starship-traditional.toml` - Traditional bash-style prompt

**Key features**:
- Context-aware information (git, python, node versions)
- Conda environment display
- Fast and responsive
- Highly customizable

**Requires**: Nerd Font installation

**See**: [starship/README.md](starship/README.md) for installation and configuration.

---

### UV (Python)

Extremely fast Python package installer and resolver (10-100x faster than pip).

**Location**: `uv/`

**What's included**:
- README with comprehensive usage guide
- Example workflow for new projects

**Key features**:
- Drop-in replacement for pip
- Compatible with requirements.txt and pyproject.toml
- Fast dependency resolution
- Built-in virtual environment management

**Quick start**:
```bash
# Install
brew install uv

# Create project
mkdir my-project && cd my-project
uv init
uv venv
source .venv/bin/activate
uv add pandas numpy
```

**See**: [uv/README.md](uv/README.md) and [uv/example-new-project.md](uv/example-new-project.md)

---

### NVM (Node.js)

Node Version Manager for installing and switching between Node.js versions.

**Location**: `nvm/`

**What's included**:
- `.nvmrc` - Default Node version (LTS Iron / 20.x)
- README with comprehensive usage guide

**Key features**:
- Multiple Node versions on one system
- Per-project version management with `.nvmrc`
- No sudo required
- Easy version switching

**Quick start**:
```bash
# Install (via Homebrew)
brew install nvm

# Install Node LTS
nvm install --lts
nvm alias default lts/*

# Use .nvmrc in projects
cd my-project
nvm use
```

**See**: [nvm/README.md](nvm/README.md) for detailed usage.

---

### VSCode

**Location**: `vscode/`

**Status**: To be configured

This directory is reserved for VSCode settings and extension lists. Configuration will be customized from scratch.

---

## Setup Checklist

Use this checklist to track your setup progress:

### System Prerequisites
- [ ] Install Xcode Command Line Tools
- [ ] Install Homebrew
- [ ] Verify Homebrew PATH configuration

### Core Tools
- [ ] Install modern bash (`brew install bash`)
- [ ] Install bash-completion (`brew install bash-completion@2`)
- [ ] Change default shell to Homebrew bash (optional)

### Development Tools
- [ ] Install Starship (`brew install starship`)
- [ ] Install Nerd Font (`brew install --cask font-fira-code-nerd-font`)
- [ ] Configure terminal to use Nerd Font
- [ ] Install UV (`brew install uv`)
- [ ] Install NVM (`brew install nvm`)
- [ ] Install direnv (`brew install direnv`)

### Configuration Files
- [ ] Copy bash configuration files (`.bashrc`, `.bash_profile`, `.bash_custom_functions`)
- [ ] Copy Starship configuration to `~/.config/starship.toml`
- [ ] Reload shell (`source ~/.bash_profile`)

### Verification
- [ ] Verify bash version (`bash --version` → should be 5.x+)
- [ ] Verify Starship (`starship --version`)
- [ ] Verify UV (`uv --version`)
- [ ] Verify NVM (`nvm --version`)
- [ ] Install Node.js LTS (`nvm install --lts`)
- [ ] Test prompt shows git branch and tool versions

### Optional Tools
- [ ] Install VSCode (`brew install --cask visual-studio-code`)
- [ ] Install Docker Desktop (`brew install --cask docker`)
- [ ] Install GNU utilities (`brew install coreutils findutils gnu-sed`)
- [ ] Install other tools as needed

---

## Platform Notes

### Apple Silicon (M1/M2/M3) vs Intel

**Homebrew Location**:
- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local`

The included `.bashrc` handles both automatically.

**Rosetta 2** (if needed for older software):
```bash
softwareupdate --install-rosetta
```

### Bash Version

macOS ships with bash 3.2 (from 2007) due to licensing. The Homebrew version (5.x+) is recommended:

```bash
# Check current version
bash --version

# After brew install bash
/opt/homebrew/bin/bash --version  # Apple Silicon
/usr/local/bin/bash --version     # Intel
```

### Terminal.app vs iTerm2

Both work well. iTerm2 offers more features:

```bash
brew install --cask iterm2
```

Configure either to use your Nerd Font for proper icon display.

---

## Additional Resources

### Official Documentation
- [Homebrew](https://brew.sh/)
- [Starship](https://starship.rs/)
- [UV](https://github.com/astral-sh/uv)
- [NVM](https://github.com/nvm-sh/nvm)

### Repository Resources
- [Python Templates](../../python/) - Project templates with pyproject.toml, Makefile, etc.
- [Conda Templates](../../conda/) - Conda environment templates
- [Git Configuration](../../git/) - Git configs and scripts
- [Main README](../../README.md) - Full repository documentation

### Related Setups
- [Linux/Ubuntu Setup](../../scripts/) - Automated setup scripts for Linux
- [Windows Setup](../../windows/) - PowerShell environment for Windows

---

## Troubleshooting

### Bash configuration not loading
```bash
# Check if .bash_profile exists and sources .bashrc
cat ~/.bash_profile

# Should contain:
# if [ -f ~/.bashrc ]; then
#     source ~/.bashrc
# fi
```

### Starship prompt not showing
```bash
# Verify starship is installed
which starship

# Check config exists
ls ~/.config/starship.toml

# Verify .bashrc has starship init
grep starship ~/.bashrc
```

### Homebrew commands not found
```bash
# Check PATH
echo $PATH

# Should include /opt/homebrew/bin or /usr/local/bin

# Add to .bash_profile if missing
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
```

### NVM not working
```bash
# Check NVM_DIR is set
echo $NVM_DIR

# Should output: /Users/yourusername/.nvm

# Reload bash profile
source ~/.bash_profile
```

---

## Next Steps

After completing basic setup:

1. **Customize your environment**: Edit `.bashrc`, `starship.toml`, add aliases
2. **Set up SSH keys**: Follow the guide in [../../README.md](../../README.md#initial-setup-github-ssh-connection)
3. **Create a project**: Use [uv/example-new-project.md](uv/example-new-project.md) as a guide
4. **Configure VSCode**: Return to `vscode/` for editor setup
5. **Explore templates**: Check out Python, conda, and other templates in the repository

---

## Contributing

Found an issue or have improvements? The `.fresh` repository is designed to be customized. Fork it, adapt it, make it your own!

---

**Happy coding! 🚀**