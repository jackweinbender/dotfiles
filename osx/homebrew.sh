#!/usr/bin/env bash

# Update Homebrew
brew update

# Upgrade All
brew upgrade

# Terminal Deps
brew install zsh
brew install make

# Fonts
brew tap caskroom/fonts
brew cask install font-hack
brew cask install font-linux-libertine

# Cask
brew cask install google-chrome
brew cask install firefox
brew cask install dashlane
brew cask install lastpass
brew cask install dropbox
brew cask install google-drive-file-stream
brew cask install keepingyouawake
brew cask install flux
brew cask install visual-studio-code
brew cask install etcher
brew cask install transmission
brew cask install spotify

# Remove outdated versions from the cellar.
brew cleanup
