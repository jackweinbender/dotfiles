#!/usr/bin/env zsh

# Core (Don't use Apple's version)
brew install git
brew install bitwarden-cli
brew install ykman

# Development Infra
brew install docker
brew install postgresql
brew install redis
brew install watchman
brew install kubectl
brew install awscli
brew install aws-iam-authenticator
brew install ansible

# Languages
brew install nvm
brew install rbenv
brew install rustup
brew install python3

# Cask
brew install --cask iterm2
brew install --cask brave-browser
brew install --cask firefox
brew install --cask visual-studio-code
brew install --cask spotify

# Start Services
brew services start docker
brew services start postgresql
brew services start redis
