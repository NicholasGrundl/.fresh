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
#
# macOS Bash Configuration
# Adapted from the .fresh repository bash configuration for macOS systems
#
################################################################################

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

# Enable ** pattern matching for recursive globbing
shopt -s globstar


# ============================================================================
# PATH & ENVIRONMENT VARIABLES
# ============================================================================

# Homebrew Configuration (Apple Silicon and Intel)
if [ -d "/opt/homebrew/bin" ]; then
    # Apple Silicon Macs (M1/M2/M3)
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [ -d "/usr/local/bin" ]; then
    # Intel Macs
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# Add user local bin to PATH
export PATH="$HOME/.local/bin:$PATH"


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
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w'
else
    PS1='\u@\h:\w'
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
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

unset color_prompt force_color_prompt

# Step 3: Starship Override
# -------------------------
# If starship is installed, use it instead of the default prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi


# ============================================================================
# COLORS & ALIASES
# ============================================================================
# Enable color support of ls (macOS uses BSD ls)
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# Alias for GNU-style ls if installed via brew
if command -v gls &> /dev/null; then
    alias ls='gls --color=auto'
    alias ll='gls -alF --color=auto'
    alias la='gls -A --color=auto'
    alias l='gls -CF --color=auto'
else
    # macOS BSD ls aliases
    alias ll='ls -alFG'
    alias la='ls -AG'
    alias l='ls -CFG'
fi

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


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
    # macOS (Homebrew)
    if type brew &>/dev/null; then
        HOMEBREW_PREFIX="$(brew --prefix)"
        if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
            source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
        else
            for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
                [[ -r "$COMPLETION" ]] && source "$COMPLETION"
            done
        fi
    # Linux
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
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
# This section will be auto-populated when you install conda/miniconda
__conda_setup="$('/Users/yourusername/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/yourusername/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/yourusername/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/yourusername/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# # Add a conda prompt prefix
if command -v conda &> /dev/null; then
    PS1="\[\033[01;36m\]"'($(basename "$CONDA_DEFAULT_ENV"))'"\[\033[90m\]:""$PS1"
fi

# >>> NVM initialize >>>
# NVM (Node Version Manager) initialization
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # This loads nvm
    . "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
    # This loads nvm bash_completion
    . "$NVM_DIR/bash_completion"
fi


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
fi