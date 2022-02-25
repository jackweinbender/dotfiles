#! /bin/bash

# Check for GIT
if ! command -v git &> /dev/null
then
    echo "Installing XCode Dev Tools..."
    xcode-select --install
    read -r -p "Once installation is complete, press any key to continue..." key
fi

read -p "Would you like to check for updates to MacOS before proceeding? [Y/n]" -n 1 -r
echo ''
if [[ $REPLY =~ ^[Nn]$ ]]
then
    softwareupdate -a -l
fi
echo ''

# Clone dotfiles
git clone https://github.com/jackweinbender/dotfiles.git $HOME/.dotfiles

# Terminal / ZSH Setup
source $HOME/.dotfiles/zsh/bootstrap.sh

# Source MacOS Initialization:
source $HOME/.dotfiles/osx/brew-init.sh
source $HOME/.dotfiles/osx/brew.sh
