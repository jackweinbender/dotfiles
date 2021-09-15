#! /bin/bash

# Based on the build instructions from the git repo.
# Recommended to build from source because the AUR
# version doesn't apply the keybindings (Sept., 2021) 

# Install build dependencies
sudo pacman -S --noconfirm git typescript make

# Cleanup and get in position
rm -rf "$HOME/tmp" && cd "$HOME" || return

# Clone the repo into a tmp dir
git clone https://github.com/pop-os/shell.git "$HOME/tmp"

# Make  the project
make --directory="$HOME/tmp" depcheck compile install configure enable

# Cleanup
rm -rf "$HOME/tmp"