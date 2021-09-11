#! /bin/bash

# This init script assumes that zsh has already been installed.
# As of Sept. 2021, zsh is installed by default in MacOS, but 
# for other OSes, you may need to install it first using the
# appropriate package manager.

# REQUIREMENTS
# 1. git
# 2. zsh

# Cleanup old install, if present
rm -rf ~/.oh-my-zsh

# Install oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# Create the template local file to ~/.zshrc
echo "# ZSHRC file for $USER@$HOSTNAME [$(date +%m-%d-%Y)]\n" > ~/.zshrc

# Bootstrap variables
cwd="$(dirname $(readlink -f $0))"
DOTFILES="$(dirname "$cwd")"

echo "export DOTFILES=$DOTFILES\n" >> ~/.zshrc

# include the base .zshrc file from this repo
echo "source $DOTFILES/zsh/.zshrc\n" >> ~/.zshrc