# Installing Claude Code on Windows

## Prerequisites
- Windows machine with PowerShell
- nvm-windows installed (via official installer from https://github.com/coreybutler/nvm-windows)

## Installation Steps

### 1. Install Node.js LTS
```powershell
# List available Node.js versions
nvm list available

# Install the latest LTS version (24.x as of Nov 2025)
nvm install 24.11.1

# Activate the installed version
nvm use 24.11.1

# Verify installation
node --version
npm --version
```

### 2. Install Claude Code
```powershell
# Install Claude Code globally via npm
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

### 3. Authenticate
```powershell
# Authenticate with Anthropic account (opens browser)
claude auth login
```

## Notes

- This installation is completely separate from any WSL installation
- Node.js via nvm-windows is preferred over conda for system-wide tools
- If `claude` command isn't found after install, restart PowerShell
- nvm-windows remembers the last `nvm use` command across sessions

## Troubleshooting

- **Command not found after install:** Restart PowerShell terminal
- **Permission errors:** Run PowerShell as Administrator if needed
- **Path issues:** Verify nvm-windows is in your PATH