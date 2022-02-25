#! /bin/bash

function install_devtools(){
    echo "Installing XCode Dev Tools..."
    xcode-select --install
    read -r -p "Once installation is complete, press any key to continue..." key
}

function update_osx(){
    softwareupdate -a -l
}

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
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
ask_yes_or_no();

clone_dotfiles();
setup_zsh();
brew_init();
install_brew_recipes();
