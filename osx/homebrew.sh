#!/usr/bin/env bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrew Config
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
source $HOME/.zprofile

# Install Git
brew install git

# Update Homebrew
brew update

# Upgrade All
brew upgrade

# Cask
brew cask install brave-browser
brew cask install firefox
brew cask install visual-studio-code
brew cask install spotify

# Remove outdated versions from the cellar.
brew cleanup
