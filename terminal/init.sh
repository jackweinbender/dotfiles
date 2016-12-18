#!/usr/bin/env bash

# Install zsh and packages
brew install zsh zsh-completions

# Install Zim with zsh
zsh -e ~/.dotfile/terminal/zim-setup.sh

# Set the default shell to zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
