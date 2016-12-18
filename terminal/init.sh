#!/usr/bin/env bash

# Install zsh and packages
brew install zsh zsh-completions

# Clone Zim
git clone --recursive https://github.com/Eriner/zim.git ${ZDOTDIR:-${HOME}}/.zim

# Install Zim with zsh
zsh -e ~/.dotfile/terminal/terminal-zim.sh

# Set the default shell to zsh
sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
