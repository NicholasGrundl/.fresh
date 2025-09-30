################################################################################
#                                                                              #
#                     macOS Bash Profile Configuration                         #
#                                                                              #
################################################################################
#
# This file is executed for login shells on macOS. It sources .bashrc to ensure
# consistent behavior across login and non-login shells.
#
# On macOS, Terminal.app runs bash as a login shell by default, so this file
# is executed first. We source .bashrc here to load all our customizations.
#
################################################################################

# Load .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# Add any login shell-specific configurations below this line
# (These will only run once when you first log in)

# Example: Set default editor
export EDITOR='nano'
