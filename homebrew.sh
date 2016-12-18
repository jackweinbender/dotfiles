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

# Remove outdated versions from the cellar.
brew cleanup
