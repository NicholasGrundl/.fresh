# .fresh

A comprehensive toolkit for setting up new development environments across Linux, macOS, and Windows. This repository contains configuration templates, setup scripts, and environment management tools to get you up and running quickly with a consistent, production-ready development setup.

## Table of Contents

- [Initial Setup: GitHub SSH Connection](#initial-setup-github-ssh-connection)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Components](#components)
  - [Conda Environment Template](#conda-environment-template)
  - [Python Project Templates](#python-project-templates)
  - [Editor Configurations](#editor-configurations)
  - [Setup Scripts (Linux/Ubuntu)](#setup-scripts-linuxubuntu)
  - [Starship Prompt](#starship-prompt)
  - [Windows PowerShell Environment](#windows-powershell-environment)
- [Platform-Specific Guides](#platform-specific-guides)
- [Prerequisites](#prerequisites)
- [Usage Examples](#usage-examples)
- [Customization](#customization)
- [Roadmap](#roadmap)

---

## Initial Setup: GitHub SSH Connection

Before cloning this repository, you'll need to set up a secure SSH connection to GitHub. This is a one-time setup that enables you to clone the repo and use the automated scripts it contains.

### Step 1: Create SSH Directory and Key

On your new machine, create the `.ssh` directory and generate a new SSH key:

```bash
# Create .ssh directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate a new SSH key (use your GitHub email)
ssh-keygen -t ed25519 -C "your_email@example.com"
# When prompted, save to: /home/yourusername/.ssh/id_ed25519
# Add a passphrase for extra security (recommended)
```

**Alternative: Copy existing SSH keys**

If you have SSH keys from a previous machine, you can copy them instead:

```bash
# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy your existing keys to the new machine
# (use a USB drive, secure file transfer, or your preferred method)
cp /path/to/backup/id_ed25519 ~/.ssh/
cp /path/to/backup/id_ed25519.pub ~/.ssh/

# Set proper permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Step 2: Add SSH Key to GitHub

1. Copy your public key to clipboard:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Go to GitHub: **Settings** → **SSH and GPG keys** → **New SSH key**

3. Give it a descriptive title (e.g., "MacBook Pro 2025")

4. Paste your public key into the "Key" field

5. Click **Add SSH key**

### Step 3: Activate SSH Key and Clone Repository

Manually start the SSH agent and add your key for this session:

```bash
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_ed25519

# Test the connection
ssh -T git@github.com
# You should see: "Hi username! You've successfully authenticated..."

# Clone this repository
git clone git@github.com:NicholasGrundl/.fresh.git
cd .fresh
```

**Note:** Once cloned, this repository contains scripts to manage SSH connections automatically. You won't need to manually activate the SSH agent for future sessions.

---

## Quick Start

### Linux/Ubuntu
```bash
# Clone the repository (after SSH setup)
git clone git@github.com:NicholasGrundl/.fresh.git
cd .fresh

# Run automated setup (installs packages, Docker, kubectl, GCloud SDK)
cd scripts
./setup_environment.sh
```

### macOS
```bash
# Clone the repository
git clone git@github.com:NicholasGrundl/.fresh.git
cd .fresh

# Copy configurations you need
cp conda/base_template.yml ~/
cp -r python/* ~/your-project/
cp starship/starship.njg.toml ~/.config/starship.toml
```

### Windows
```powershell
# Clone the repository
git clone git@github.com:NicholasGrundl/.fresh.git
cd .fresh\windows

# Follow the Windows-specific setup guide
Get-Content .\README.md
```

---

## Repository Structure

```
.fresh/
├── conda/                  # Conda environment templates
│   └── base_template.yml  # Base environment with essential tools
├── editors/                # Editor configurations
│   ├── jupyter_lab_config.py    # JupyterLab settings
│   └── settings.json            # VS Code configuration
├── python/                 # Python project templates
│   ├── Makefile           # Common development tasks
│   ├── pyproject.toml     # Modern Python packaging config
│   ├── requirements.txt   # Production dependencies
│   ├── requirements-dev.txt     # Development dependencies
│   ├── requirements-build.txt   # Build dependencies
│   ├── setup.cfg          # Package metadata
│   └── setup.cfg.sh       # Setup configuration helper
├── scripts/                # Automated setup scripts (Linux)
│   ├── check_environment.sh     # Verify installation
│   ├── required_packages.txt    # System packages list
│   └── setup_environment.sh     # Main setup script
├── starship/               # Terminal prompt configurations
│   ├── starship.fredericrous.toml   # Custom prompt style
│   └── starship.njg.toml            # Alternative prompt style
└── windows/                # Windows-specific setup
    ├── DiagnosticFunctions.ps1      # System diagnostics
    ├── EnvFunctions.ps1             # Environment management
    ├── SSHFunctions.ps1             # SSH automation
    ├── install_dependencies.ps1     # Package installation
    ├── uninstall_dependencies.ps1   # Package removal
    ├── profile.ps1                  # PowerShell profile
    └── README.md                    # Windows setup guide
```

---

## Components

### Conda Environment Template

**Location:** `conda/base_template.yml`

A comprehensive base environment with modern development tools pre-configured:

- **Python:** 3.12.11 with pip, setuptools, and wheel
- **CLI Tools:** bat, fd-find, ripgrep, tree, jq
- **Version Control:** git 2.49.0
- **Modern Tools:** direnv, starship prompt, uv (fast Python package installer)
- **Development:** Node.js 24.4.1 for tooling

**Usage:**
```bash
# Create environment from template
conda env create -f conda/base_template.yml

# Activate environment
conda activate base_template

# Update template for your needs
conda env export > my_environment.yml
```

**Key Features:**
- Optimized for Linux but portable across platforms
- Uses conda-forge as primary channel for latest packages
- Includes bioconda for bioinformatics tools
- Pre-configured with modern alternatives (bat > cat, fd > find, ripgrep > grep)

### Python Project Templates

**Location:** `python/`

Production-ready Python project configuration files:

#### `pyproject.toml`
Modern Python packaging configuration with:
- **Build System:** setuptools backend
- **Testing:** pytest with coverage reporting and structured logging
- **Linting/Formatting:** Ruff configuration (120 char line length, Python 3.12 target)
- **Import Sorting:** isort rules for clean imports
- **Style:** PEP 257 docstring conventions

#### `Makefile`
Common development tasks automated:
```bash
make install      # Install all dependencies
make uninstall    # Remove all packages
make test         # Run tests with coverage
make lint         # Check code style
make format       # Auto-format code
make pre-commit   # Format, lint, and test
make jupyter      # Start JupyterLab
```

#### Requirements Files
- `requirements.txt` - Production dependencies
- `requirements-dev.txt` - Development tools (pytest, ruff, etc.)
- `requirements-build.txt` - Build tools

#### `setup.cfg`
Package metadata and tool configurations

**Usage:**
```bash
# Copy to your project
cp -r .fresh/python/* ~/my-project/

# Install dependencies
cd ~/my-project
make install

# Run development workflow
make pre-commit
```

### Editor Configurations

**Location:** `editors/`

#### VS Code Settings (`settings.json`)
- Custom terminal color scheme for improved readability
- Commented sections for Jupyter notebook customization (light/dark themes)
- Clean ANSI color palette for terminal output

**Usage:**
```bash
# Copy to VS Code settings
cp editors/settings.json ~/.config/Code/User/settings.json
# Or on macOS:
cp editors/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

#### JupyterLab Config (`jupyter_lab_config.py`)
Custom JupyterLab configuration for optimal notebook experience.

**Usage:**
```bash
# Copy to Jupyter config directory
mkdir -p ~/.jupyter
cp editors/jupyter_lab_config.py ~/.jupyter/
```

### Setup Scripts (Linux/Ubuntu)

**Location:** `scripts/`

Automated setup for Linux systems with common development tools.

#### `setup_environment.sh`
Main setup script that installs:
- **Google Cloud SDK:** For GCP development
- **Docker:** Container runtime with user permissions
- **kubectl:** Kubernetes command-line tool
- **System Packages:** From `required_packages.txt`

**Usage:**
```bash
cd scripts
./setup_environment.sh
# Log out and back in for Docker permissions to take effect
```

#### `check_environment.sh`
Verify installed components and diagnose issues.

#### `required_packages.txt`
List of system packages to install. Customize for your needs.

**Features:**
- Idempotent: Safe to run multiple times
- Skips already-installed packages
- Adds user to docker group automatically
- Sets up Google Cloud SDK repository

### Starship Prompt

**Location:** `starship/`

Custom terminal prompt configurations for the [Starship](https://starship.rs/) cross-shell prompt.

#### Features:
- **Environment Info:** Shows conda environment, Python version, Node.js version
- **User Context:** Username and hostname always visible
- **Directory:** Smart truncation with repo root highlighting
- **Git Status:** Branch, ahead/behind, changes, and status indicators
- **Minimal:** Clean, information-dense without clutter

#### Format Example:
```
(conda_env)(py3.12)(npm24.4):username@hostname:~/path/to/dir:(main)$
```

**Usage:**
```bash
# Install starship (if not in conda environment)
curl -sS https://starship.rs/install.sh | sh

# Copy configuration
cp starship/starship.njg.toml ~/.config/starship.toml

# Or try the alternative style
cp starship/starship.fredericrous.toml ~/.config/starship.toml

# Add to your shell config (~/.bashrc or ~/.zshrc)
eval "$(starship init bash)"  # or 'zsh'
```

### Windows PowerShell Environment

**Location:** `windows/`

Complete Windows development environment setup with PowerShell automation.

#### Components:

**`profile.ps1`** - PowerShell profile with custom functions and SSH automation

**`EnvFunctions.ps1`** - Environment management utilities:
- Conda environment activation helpers
- Path management
- Environment variable utilities

**`SSHFunctions.ps1`** - SSH persistence management:
- Automatic SSH agent startup
- Key management
- Git authentication automation

**`DiagnosticFunctions.ps1`** - System diagnostics:
- Environment checks
- Dependency verification
- Troubleshooting tools

**`install_dependencies.ps1`** - Python package installation:
- Reads from `requirements.txt`
- Creates `requirements-lock.txt` with pinned versions
- Conda environment aware

**`uninstall_dependencies.ps1`** - Clean package removal:
- Removes all pip packages
- Cleans lock files

#### Setup Process:

1. **Install Miniconda:**
   ```powershell
   # Download from https://docs.conda.io/en/latest/miniconda.html
   # Add to PATH during installation
   conda --version  # Verify
   ```

2. **Enable PowerShell Scripts:**
   ```powershell
   # Check current policy
   Get-ExecutionPolicy

   # Enable scripts (as Administrator)
   Set-ExecutionPolicy RemoteSigned
   ```

3. **Initialize Conda:**
   ```powershell
   conda init powershell
   ```

4. **Create Environment:**
   ```powershell
   conda create --name myenv python=3.12 pip
   conda activate myenv
   ```

5. **Install Dependencies:**
   ```powershell
   .\install_dependencies.ps1
   ```

For complete Windows setup instructions, see `windows/README.md`.

---

## Platform-Specific Guides

### Linux/Ubuntu

**Best For:** Servers, cloud instances, automated deployments

1. Clone repository
2. Run `scripts/setup_environment.sh`
3. Create conda environment from `conda/base_template.yml`
4. Copy Python templates to projects
5. Configure starship prompt

### macOS

**Best For:** Local development, data science, general use

1. Install [Homebrew](https://brew.sh/)
2. Install Miniconda: `brew install miniconda`
3. Clone repository
4. Create conda environment from template
5. Copy configurations as needed
6. Set up starship prompt

### Windows

**Best For:** Windows-specific development, COM automation, Excel integration

1. Install Miniconda and Git
2. Configure PowerShell execution policy
3. Follow `windows/README.md` for complete setup
4. Use provided PowerShell functions for automation

---

## Prerequisites

### All Platforms
- Git
- SSH access to GitHub
- Internet connection for package downloads

### Linux/Ubuntu
- Ubuntu 20.04+ or compatible
- sudo access
- apt package manager

### macOS
- macOS 10.15+ (Catalina or later)
- Homebrew (recommended)
- Command Line Tools for Xcode

### Windows
- Windows 10/11
- PowerShell 5.1+
- Administrator access (for initial setup)
- Miniconda or Anaconda

---

## Usage Examples

### Setting Up a New Python Project

```bash
# Create project directory
mkdir ~/my-awesome-project
cd ~/my-awesome-project

# Copy Python templates
cp ~/.fresh/python/* .

# Edit requirements files for your dependencies
nano requirements.txt

# Install dependencies
make install

# Start development
make jupyter  # Or start coding!
```

### Creating a Custom Conda Environment

```bash
# Start from base template
cp ~/.fresh/conda/base_template.yml my-project-env.yml

# Edit to add your packages
nano my-project-env.yml

# Create environment
conda env create -f my-project-env.yml
conda activate my-project-env
```

### Customizing Your Terminal

```bash
# Install starship
conda install -c conda-forge starship
# Or: curl -sS https://starship.rs/install.sh | sh

# Copy configuration
cp ~/.fresh/starship/starship.njg.toml ~/.config/starship.toml

# Customize colors, format, modules
nano ~/.config/starship.toml

# Add to shell (bash/zsh)
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

### Windows: Managing Python Packages

```powershell
# Activate environment
conda activate myenv

# Install packages from requirements.txt
.\install_dependencies.ps1

# Check installed versions
pip list

# Uninstall all packages if needed
.\uninstall_dependencies.ps1
```

---

## Customization

This repository is designed as a starting point. Customize it for your needs:

### Modifying the Conda Template
```bash
# Edit the template
nano conda/base_template.yml

# Add packages:
dependencies:
  - your-package-name=version

# Or add pip packages:
  - pip:
    - your-pip-package
```

### Adapting Python Configs
- Adjust line length in `pyproject.toml` (Ruff section)
- Modify test coverage requirements in Makefile
- Add custom make targets for your workflow
- Update Python version in `pyproject.toml` target-version

### Customizing Starship
- Change colors: modify style values in `.toml` file
- Add/remove modules: comment out sections you don't need
- Adjust truncation: change `truncation_length` in directory section
- Add custom symbols: update symbol fields

### Extending Windows Scripts
- Add functions to `EnvFunctions.ps1`
- Customize SSH behavior in `SSHFunctions.ps1`
- Add diagnostic checks in `DiagnosticFunctions.ps1`
- Modify package management in install/uninstall scripts

---

## Roadmap

- [x] Reorganize repository structure
- [x] Add automated setup scripts
- [x] Document all tools and configurations
- [ ] Create modular installation options
- [ ] Add Docker-based development environments
- [ ] Include pre-commit hook templates
- [ ] Add CI/CD pipeline examples
- [ ] Create automated testing for setup scripts
- [ ] Add support for additional shells (fish, nushell)