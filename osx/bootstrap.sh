#! /bin/bash

# Download this file, make it executable, and run it.

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Git
brew install git

# Clone dotfiles
git clone https://github.com/jackweinbender/dotfiles.git ~/.dotfiles

read -p  "You may wish to edit the setup file.\npress any key to continue, or CTRL + C to abort."

# Run the installer
./~/.dotfiles/osx/osx-setup.sh