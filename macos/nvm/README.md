# NVM - Node Version Manager for macOS

NVM allows you to install and switch between multiple versions of Node.js on your system. This is essential for working on different projects that require different Node versions.

## Why NVM?

- **Multiple Node versions**: Switch between versions easily
- **Per-project versions**: Use `.nvmrc` files to specify Node version per project
- **No sudo required**: Installs Node in your home directory
- **Automatic switching**: Can auto-switch when entering directories with `.nvmrc`

## Installation

### Method 1: Install via Homebrew (Recommended)

```bash
brew install nvm
```

After installation, follow the post-install instructions to add NVM to your shell configuration.

```
You should create NVM's working directory if it doesn't exist:
  mkdir ~/.nvm

Add the following to your shell profile e.g. ~/.profile or ~/.zshrc:
  export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

You can set $NVM_DIR to any location, but leaving it unchanged from
/usr/local/Cellar/nvm/0.40.3 will destroy any nvm-installed Node installations
upon upgrade/reinstall.
```

### Method 2: Install via Official Script

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### Post-Installation Setup

The `.bashrc` file in `../bash/` already includes NVM initialization:

```bash
# NVM (Node Version Manager) initialization
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
    . "$NVM_DIR/bash_completion"
fi
```

### Verify Installation

```bash
# Reload your shell
source ~/.bash_profile

# Check NVM version
nvm --version
```

## Basic Usage

### Installing Node Versions

```bash
# Install latest LTS version
nvm install --lts

# Install latest version
nvm install node

# Install specific version
nvm install 18.17.0
nvm install 20.0.0

# Install version by LTS codename
nvm install lts/iron     # Node 20.x
nvm install lts/hydrogen # Node 18.x
```

### Switching Node Versions

```bash
# List installed versions
nvm list

# Switch to a version
nvm use 18.17.0

# Switch to latest LTS
nvm use --lts

# Switch to system Node (if installed)
nvm use system
```

### Setting Default Version

```bash
# Set default Node version
nvm alias default lts/iron

# Or specific version
nvm alias default 20.0.0
```

### Managing Versions

```bash
# List all available versions
nvm ls-remote

# List available LTS versions
nvm ls-remote --lts

# Uninstall a version
nvm uninstall 18.0.0
```

## Using .nvmrc Files

The `.nvmrc` file specifies which Node version a project should use.

### Creating .nvmrc

```bash
# In your project directory
echo "lts/iron" > .nvmrc

# Or specify exact version
echo "20.9.0" > .nvmrc

# Or use current version
node -v > .nvmrc
```

### Using .nvmrc

```bash
# When entering a project directory with .nvmrc
cd my-project

# Use the version specified in .nvmrc
nvm use

# Or install if not present
nvm install
```

### Default .nvmrc (Included)

This directory includes a `.nvmrc` with `lts/iron` (Node 20.x LTS) as a recommended default for new projects.

## Automatic Version Switching

### Option 1: Manual with Bash Function

Add this to your `~/.bash_custom_functions`:

```bash
# Automatically use .nvmrc version when entering directory
cd() {
    builtin cd "$@"
    if [ -f .nvmrc ]; then
        nvm use
    fi
}
```

### Option 2: Use avn or direnv

Install additional tools for automatic switching:

```bash
# Using direnv (already in .bashrc)
brew install direnv

# Add to .envrc in project:
echo "use nvm" > .envrc
direnv allow
```

## Common Workflows

### Starting a New Node Project

```bash
# Create project directory
mkdir my-node-project
cd my-node-project

# Copy default .nvmrc
cp ~/.fresh/macos/nvm/.nvmrc .

# Use specified Node version
nvm install
nvm use

# Initialize npm project
npm init -y

# Install dependencies
npm install express
```

### Switching Between Projects

```bash
# Project A uses Node 18
cd ~/projects/project-a
nvm use    # Reads .nvmrc

# Project B uses Node 20
cd ~/projects/project-b
nvm use    # Reads .nvmrc
```

## Integration with Other Tools

### npm Global Packages

Global packages are installed per-Node-version:

```bash
# Install global package for current Node version
npm install -g typescript

# List global packages for current version
npm list -g --depth=0
```

To share globals across versions:

```bash
# After installing new Node version
nvm install 20
nvm reinstall-packages 18
```

### With Yarn

```bash
# Install Yarn globally for current Node version
npm install -g yarn

# Or use Corepack (comes with Node 16+)
corepack enable
```

### With pnpm

```bash
# Install pnpm
npm install -g pnpm

# Or use standalone install
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## Troubleshooting

### NVM command not found

```bash
# Reload shell configuration
source ~/.bash_profile

# Check if NVM_DIR is set
echo $NVM_DIR

# Should output: /Users/yourusername/.nvm
```

### Node version not persisting

```bash
# Set default version
nvm alias default lts/iron

# Verify
nvm list
```

### Slow shell startup

NVM initialization can slow shell startup. Options:

1. **Lazy loading**: Only load NVM when needed
2. **Use faster alternatives**: Consider fnm (Fast Node Manager)

```bash
# Install fnm (alternative to nvm)
brew install fnm

# Add to .bashrc
eval "$(fnm env --use-on-cd)"
```

### Permission errors

If you get permission errors:

```bash
# Don't use sudo with npm!
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'

# Add to PATH in .bashrc
export PATH=~/.npm-global/bin:$PATH
```

## Updating NVM

### Via Homebrew

```bash
brew upgrade nvm
```

### Via Install Script

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bash_profile
```

## Node.js LTS Schedule

| Version | Codename | LTS Start | Active Until | Maintenance Until |
|---------|----------|-----------|--------------|-------------------|
| 20.x | Iron | Oct 2023 | Apr 2025 | Apr 2026 |
| 22.x | (Next) | Oct 2024 | Apr 2026 | Apr 2027 |

**Recommendation**: Use `lts/iron` (Node 20.x) for most projects.

## See Also

- [Official NVM Repository](https://github.com/nvm-sh/nvm)
- [Node.js Release Schedule](https://nodejs.org/en/about/releases/)
- [UV Setup](../uv/) - Python equivalent
- [Bash Setup](../bash/) - Includes NVM initialization