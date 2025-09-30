# Starship Prompt for macOS

Starship is a minimal, fast, and customizable prompt for any shell. It shows relevant information about your development environment (git status, language versions, conda environment, etc.) in a clean, configurable format.

## Contents

- `starship-traditional.toml` - Nicholas's custom configuration (matches traditional bash prompt style)

## Features

### General Features
- Fast (written in Rust)
- Works with bash, zsh, fish, and more
- Shows context-aware information:
  - Git branch and status
  - Python/Node.js versions
  - Conda environment
  - Directory path with smart truncation
  - Command duration
  - And much more

### Configuration Highlights

**starship-traditional.toml**
- Traditional prompt style: `(conda_env):user@hostname:~/path:(git_branch)$`
- Minimal git status indicators
- Clean, readable colors

## Installation

### 1. Install Starship

```bash
brew install starship
```

### 2. Install a Nerd Font (Required)

Starship uses special icons that require a Nerd Font. Choose one of these popular options:

**FiraCode Nerd Font** (Recommended)
```bash
brew install --cask font-fira-code-nerd-font
```

**Other Options**
```bash
# MesloLGS NF (used by many terminal themes)
brew install --cask font-meslo-lg-nerd-font

# JetBrains Mono (popular for coding)
brew install --cask font-jetbrains-mono-nerd-font

# Hack Nerd Font (clean and readable)
brew install --cask font-hack-nerd-font
```

### 3. Configure Your Terminal

Set your terminal to use the Nerd Font you installed:

**Terminal.app**
1. Open Preferences (Cmd+,)
2. Go to Profiles → Text
3. Click "Change" under Font
4. Select your Nerd Font (e.g., "FiraCode Nerd Font")

**iTerm2**
1. Open Preferences (Cmd+,)
2. Go to Profiles → Text
3. Change font under "Font" section
4. Select your Nerd Font

### 4. Choose and Install a Configuration

```bash
# Copy your preferred config to the starship config location
mkdir -p ~/.config

# Option 1: Nicholas's config (traditional style)
cp starship-traditional.toml ~/.config/starship.toml
```

### 5. Enable in Bash

This is already configured in the `.bashrc` file from `../bash/`. Starship will automatically activate if it's installed.

If you're setting up manually, add this to your `~/.bashrc`:

```bash
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
```

### 6. Reload Your Shell

```bash
source ~/.bash_profile
```

## Customization

### Edit Your Configuration

```bash
# Open in your preferred editor
vim ~/.config/starship.toml
# or
code ~/.config/starship.toml
```

### Quick Tweaks

**Change colors:** Look for `style = "color"` entries in the config

**Enable/disable modules:** Set `disabled = true` or `disabled = false`

**Change prompt format:** Modify the `format = "..."` line at the top

### Configuration Documentation

Full documentation available at: https://starship.rs/config/

### Test Configuration

```bash
# Test your config for errors
starship config

# Print all detected modules
starship explain
```

## Troubleshooting

### Icons not showing
- Make sure you installed a Nerd Font (see step 2)
- Verify your terminal is using the Nerd Font (see step 3)
- Some terminals may require a restart

### Prompt not changing
- Verify starship is installed: `which starship`
- Check that eval line is in your `.bashrc`
- Make sure `.bash_profile` sources `.bashrc`
- Reload: `source ~/.bash_profile`

### Slow prompt
- Starship is generally very fast, but some modules can slow it down
- Disable expensive modules in config:
  ```toml
  [package]
  disabled = true

  [nodejs]
  disabled = true
  ```

### Config not loading
- Check config location: `~/.config/starship.toml`
- Verify valid TOML syntax: `starship config`

## Preset Themes

Starship includes many preset themes. Try them out:

```bash
# List available presets
starship preset --list

# Preview a preset
starship preset bracketed-segments

# Install a preset
starship preset bracketed-segments > ~/.config/starship.toml
```

## See Also

- [Official Starship Website](https://starship.rs/)
- [Configuration Documentation](https://starship.rs/config/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Bash Setup](../bash/) - Bash configuration that integrates with Starship