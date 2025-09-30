# Bash Setup for macOS

Complete bash shell configuration for macOS systems, including custom prompt, functions, and environment management.

## Contents

- `.bashrc` - Main bash configuration (adapted for macOS)
- `.bash_profile` - Login shell configuration (sources .bashrc)
- `.bash_custom_functions` - Custom bash functions for SSH and environment management

## Features

### Shell Behavior
- Command history management (1000 commands, no duplicates)
- Window size checking
- Enhanced tab completion (cycles through options)

### Terminal Prompt
- Colored prompt with username, hostname, and directory
- Git branch display
- Starship integration (if installed)

### Aliases
- Color-enabled `ls` commands (BSD and GNU-style if `coreutils` installed)
- Colored `grep` output
- Common shortcuts: `ll`, `la`, `l`

### Custom Functions
- `set_environment <path>` - Load environment variables from .env file
- `unset_environment <path>` - Unload environment variables
- `set_ssh` - Set up persistent SSH agent with 1-day key expiration
- `unset_ssh` - Clean up SSH agent and sockets
- `parse_git_branch` - Display current git branch in prompt

### Tool Integration
- Homebrew (Apple Silicon and Intel support)
- Direnv (per-directory environment variables)
- NVM (Node Version Manager)
- Conda/Miniconda (placeholder for initialization)
- Starship prompt (if installed)

## Installation

### 1. Install Bash via Homebrew (Optional but Recommended)

macOS ships with an older version of bash (3.x). Install a modern version:

```bash
brew install bash

# Add to allowed shells
sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells'

# Change default shell
chsh -s /opt/homebrew/bin/bash
```

### 2. Copy Configuration Files

```bash
# Backup existing configs (if any)
cp ~/.bashrc ~/.bashrc.backup 2>/dev/null
cp ~/.bash_profile ~/.bash_profile.backup 2>/dev/null

# Copy new configs
cp .bashrc ~/.bashrc
cp .bash_profile ~/.bash_profile
cp .bash_custom_functions ~/.bash_custom_functions

# Set proper permissions
chmod 644 ~/.bashrc ~/.bash_profile ~/.bash_custom_functions
```

### 3. Reload Configuration

```bash
source ~/.bash_profile
```

## Optional: GNU Utilities

macOS uses BSD versions of common utilities. Install GNU versions for consistent behavior:

```bash
brew install coreutils findutils gnu-sed gnu-tar grep

# Add to PATH in .bashrc (already configured)
```

## Optional: Bash Completion

Install enhanced bash completion for many common tools:

```bash
brew install bash-completion@2
```

This is automatically configured in the `.bashrc` file.

## Customization

### Aliases

Add custom aliases to `~/.bash_aliases`:

```bash
# Create the file
touch ~/.bash_aliases

# Add your aliases
echo "alias myalias='some command'" >> ~/.bash_aliases
```

### Additional Functions

The `.bash_custom_functions` file is sourced automatically. Add your own functions there or keep them in a separate file.

### Prompt Customization

To customize the default prompt, edit the PS1 section in `.bashrc`. For more advanced customization, consider installing and configuring Starship (see `../starship/`).

## Troubleshooting

### Bash version check
```bash
bash --version
```

Should show 5.x or higher if you installed via Homebrew.

### Check if configs are being sourced
Add a debug line to your `.bashrc`:
```bash
echo "Loading .bashrc"
```

### SSH agent not persisting
Make sure `set_ssh` function is being called. Check that `.bash_custom_functions` is being sourced by adding:
```bash
declare -f set_ssh
```

If empty, the function isn't loaded.

## See Also

- [Starship Prompt](../starship/) - Modern, fast prompt with better git integration
- [NVM Setup](../nvm/) - Node.js version management
- [UV Setup](../uv/) - Python package management