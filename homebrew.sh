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

# Cask
brew cask install google-chrome
brew cask install atom
brew cask install dashlane
brew cask install dropbox
brew cask install google-drive
brew cask install skype
brew cask install transmission

# Remove outdated versions from the cellar.
brew cleanup
