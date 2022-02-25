#! /bin/bash

function install_devtools() {
    echo "Installing XCode Dev Tools..."
    xcode-select --install
    read -r -p "Once installation is complete, press any key to continue..." key
}

# Make sure Git is installed first
command -v git || install_devtools

git clone https://github.com/jackweinbender/dotfiles.git $HOME/.dotfiles
source $HOME/.dotfiles/zsh/bootstrap.zsh
source $HOME/.dotfiles/osx/brew-init.zsh
source $HOME/.dotfiles/osx/brew.zsh
