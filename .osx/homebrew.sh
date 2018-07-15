#!/usr/bin/env bash

# Update Homebrew
brew update

# Upgrade All
brew upgrade

# CLI Tools
brew install git

# Dev Env
brew install make
brew install node
brew install rustup
brew install python3
brew install rbenv
brew install pandoc pandoc-citeproc
brew install watchman

# Terminal Deps
brew install zsh

# Cask
brew cask install google-chrome
brew cask install firefox
brew cask install visual-studio-code
brew cask install keepingyouawake
brew cask install dashlane
brew cask install lastpass
brew cask install dropbox
brew cask install google-drive-file-stream
brew cask install google-cloud-sdk
brew cask install transmission
brew cask install mactex
brew cask install font-linux-libertine

# Remove outdated versions from the cellar.
brew cleanup
