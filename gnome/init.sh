#! /bin/bash

# Install Pop stuff
source "$DOTFILES/gnome/pop_shell_install.sh"
source "$DOTFILES/gnome/pop_theme_install.sh"

# Enable Pop theme
source "$DOTFILES/gnome/pop_shell_enable_theme.sh"

# Other Gnome settings: Natural scrolling, etc.
source "$DOTFILES/gnome/settings.sh"

source "$DOTFILES/gnome/restart-shell.sh"