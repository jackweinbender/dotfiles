#!/usr/bin/env bash

# Update Homebrew
brew update

# Upgrade All
brew upgrade

# CLI Tools
brew install git

# Dev Env
brew install node
brew install elixir
brew install pandoc
brew install rust

# Terminal Deps
brew install zsh

# Cask
brew cask install google-chrome
brew cask install atom
brew cask install keepingyouawake
brew cask install dashlane
brew cask install dropbox
brew cask install google-drive
brew cask install skype
brew cask install transmission
brew cask install mactex
brew cask install google-cloud-sdk

# Remove outdated versions from the cellar.
brew cleanup
