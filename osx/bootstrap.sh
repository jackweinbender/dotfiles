#! /bin/bash

# Download this file, make it executable, and run it.

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Git
brew install git

# Clone dotfiles
git clone https://github.com/jackweinbender/dotfiles.git ~/.dotfiles
