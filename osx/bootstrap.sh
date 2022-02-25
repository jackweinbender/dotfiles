#! /bin/bash

# Check for GIT
if ! command -v <the_command> &> /dev/null
then
    echo "Installing XCode Dev Tools"
    xcode-select --install
fi

# Clone dotfiles
git clone https://github.com/jackweinbender/dotfiles.git $HOME/.dotfiles

# Source MacOS Initialization:
source $HOME/.dotfiles/zsh/bootstrap.sh
source $HOME/.dotfiles/osx/brew-init.sh
source $HOME/.dotfiles/osx/brew.sh
