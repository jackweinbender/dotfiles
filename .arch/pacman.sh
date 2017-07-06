#!/usr/bin/env bash

# Install Zsh and git
sudo pacman -S git
sudo pacman -S zsh

# GUI Utils
sudo pacman -S chromium
sudo pacman -S dropbox
sudo pacman -S lastpass

# Development
sudo pacman -S visual-studio-code
sudo pacman -S nodejs
sudo pacman -S npm
sudo pacman -S rustup

sudo npm install -g yarn
sudo npm install -g ember-cli

# TeX Stuff
sudo pacman -S atom-editor-bin
sudo pacman -S pandoc pandoc-citeproc
sudo pacman -S texlive-core texlive-localmanager-git
sudo pacman -S biber


# Other
sudo pacman -S google-cloud-sdk
