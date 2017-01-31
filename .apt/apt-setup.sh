#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install the basics
source ~/.dotfiles/apt.sh

# Setup Symlinks
source ~/.dotfiles/symlinks/init.sh

# Setup Terminal
source ~/.dotfiles/terminal/init.sh

# Kill Terminal to force Restart
echo "\n\n\Please restart Terminal.\nYou may need to logout and log back in to see the full effects."
