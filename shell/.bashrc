################################################################################
#                                                                              #
#    ███╗   ██╗██╗ ██████╗██╗  ██╗ ██████╗ ██╗      █████╗ ███████╗            #
#    ████╗  ██║██║██╔════╝██║  ██║██╔═══██╗██║     ██╔══██╗██╔════╝            #
#    ██╔██╗ ██║██║██║     ███████║██║   ██║██║     ███████║███████╗            #
#    ██║╚██╗██║██║██║     ██╔══██║██║   ██║██║     ██╔══██║╚════██║            #
#    ██║ ╚████║██║╚██████╗██║  ██║╚██████╔╝███████╗██║  ██║███████║            #
#    ╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝            #
#                                                                              #
#                                                                              #
#         ██████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ ██╗                       #
#        ██╔════╝ ██╔══██╗██║   ██║████╗  ██║██╔══██╗██║                       #
#        ██║  ███╗██████╔╝██║   ██║██╔██╗ ██║██║  ██║██║                       #
#        ██║   ██║██╔══██╗██║   ██║██║╚██╗██║██║  ██║██║                       #
#        ╚██████╔╝██║  ██║╚██████╔╝██║ ╚████║██████╔╝███████╗                  #
#         ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝                  #
#                                                                              #
#                                                                              #
#    "Science is more diverse in its terminology than its concepts"            #
#                              — Amos Ron                                      #
#                                                                              #
################################################################################

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# ============================================================================
# EARLY EXIT FOR NON-INTERACTIVE SHELLS
# ============================================================================
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# ============================================================================
# SHELL BEHAVIOR & HISTORY CONFIGURATION  
# ============================================================================
# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# History length settings
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Enable ** pattern matching (uncomment if needed)
#shopt -s globstar

# ============================================================================
# SYSTEM UTILITIES & LESS CONFIGURATION
# ============================================================================
# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# ============================================================================
# PATH & ENVIRONMENT VARIABLES
# ============================================================================
# CUDA Configuration (Dynamic version detection)
if [ -d "/usr/local/cuda" ]; then
    export PATH="/usr/local/cuda/bin${PATH:+:${PATH}}"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    # Fallback to specific version if symlink doesn't exist
elif [ -d "/usr/local/cuda-12.8" ]; then
    export PATH="/usr/local/cuda-12.8/bin${PATH:+:${PATH}}"
    export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

# Bun Runtime
if [ -d "$HOME/.local/share/reflex/bun" ]; then
    export BUN_INSTALL="$HOME/.local/share/reflex/bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi


# ============================================================================
# TERMINAL APPEARANCE & PROMPT (PS1)
# ============================================================================

# Step 1: Color Detection
# -----------------------
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt (disabled by default)
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Step 2: Build PS1 Progressively
# --------------------------------
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w'
fi

# Add git branch (progressively)
if command -v git &> /dev/null; then
    parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    
    if [ "$color_prompt" = yes ]; then
        PS1+='\[\033[90m\]:\[\033[0;33m\]$(parse_git_branch)'
    else
        PS1+=':$(parse_git_branch)'
    fi
fi

# Add final prompt character
if [ "$color_prompt" = yes ]; then
    PS1+='\[\033[1;37m\]\$ '
else
    PS1+='\$ '
fi

# Set xterm title (only once, at the end)
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

unset color_prompt force_color_prompt

# Step 3: Starship Override
# -------------------------
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi


# ============================================================================
# COLORS & ALIASES
# ============================================================================
# Enable color support of ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ============================================================================
# EXTERNAL CONFIGURATIONS
# ============================================================================

# Load custom aliases if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load custom functions if they exist
if [ -f ~/.bash_custom_functions ]; then
    . ~/.bash_custom_functions
fi

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================================================
# PACKAGE MANAGERS & RUNTIME INITIALIZATION
# ============================================================================
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nicholasgrundl/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nicholasgrundl/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nicholasgrundl/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nicholasgrundl/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Add a conda prompt prefix
if command -v conda &> /dev/null; then
    PS1="\[\033[01;36m\]"'($(basename "$CONDA_DEFAULT_ENV"))'"\[\033[90m\]:""$PS1"
fi

# >>>  Docker settings >>>
# see (https://dev.to/bowmanjd/install-docker-on-windows-wsl-without-docker-desktop-34m9)
# <<< Docker Settings <<<


# ============================================================================
# DEVELOPMENT TOOLS & SHELL ENHANCEMENTS
# ============================================================================

# Direnv integration for per-directory environment variables
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

# Enhanced tab completion (cycles through options)
# Note: This changes default bash behavior - comment out if it causes issues
bind '"\t":menu-complete'


# ============================================================================
# SESSION MANAGEMENT
# ============================================================================
# SSH persistence (requires set_ssh function to be defined in custom functions)
if declare -f set_ssh > /dev/null; then
    set_ssh
else
    # Uncomment to see warning about missing function
    echo "Warning: set_ssh function not found in custom functions"
fi
