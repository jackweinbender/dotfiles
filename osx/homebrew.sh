#!/usr/bin/env bash

# Update Homebrew
brew update

# Upgrade All
brew upgrade

# CLI Tools
brew install git

# My Pandoc and CSL Settings
brew install pandoc pandoc-citeproc
git clone https://github.com/jackweinbender/dot-pandoc.git ~/.pandoc
git clone https://github.com/jackweinbender/dot-csl.git ~/.csl

# Terminal Deps
brew install zsh
brew install make

# Cask
brew cask install google-chrome
brew cask install firefox
brew cask install dashlane
brew cask install lastpass
brew cask install dropbox
brew cask install keepingyouawake
brew cask install google-drive-file-stream
brew cask install visual-studio-code
brew cask install libreoffice
brew cask install mactex
brew cask install texpad
brew cask install typora
brew cask install etcher
brew cask install flux
brew cask install spotify
brew cask install google-cloud-sdk
brew cask install transmission
brew cask install font-linux-libertine

# Remove outdated versions from the cellar.
brew cleanup
