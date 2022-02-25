#! /bin/bash

# Download this file, make it executable, and run it.

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Git
brew install git

# Clone dotfiles
git clone https://github.com/jackweinbender/dotfiles.git ~/.dotfiles
