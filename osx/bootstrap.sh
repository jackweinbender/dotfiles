#! /bin/bash

function install_devtools(){
    echo "Installing XCode Dev Tools..."
    xcode-select --install
    read -r -p "Once installation is complete, press any key to continue..." key
}

function update_osx(){
    softwareupdate -a -l
}

function prompt_for_update(){
    read -p "Would you like to check for updates to MacOS before proceeding? [Y/n]"  -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        update_osx();
    fi
}

function clone_dotfiles(){
    git clone https://github.com/jackweinbender/dotfiles.git $HOME/.dotfiles
}

function setup_zsh(){
    source $HOME/.dotfiles/zsh/bootstrap.sh
}

function brew_init(){
    source $HOME/.dotfiles/osx/brew-init.sh
}

function install_brew_recipes(){
    source $HOME/.dotfiles/osx/brew.sh
}

# Main
command -v git || install_devtools();
prompt_for_update();

clone_dotfiles();
setup_zsh();
brew_init();
install_brew_recipes();
