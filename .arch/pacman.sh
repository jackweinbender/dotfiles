#!/usr/bin/env bash

# Install Zsh and git
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm zsh
sudo pacman -S --noconfirm pacaur

# GUI Utils
sudo pacman -S --noconfirm chromium
sudo pacman -S --noconfirm dropbox
sudo pacman -S --noconfirm lastpass

# Development
sudo pacman -S --noconfirm nodejs
sudo pacman -S --noconfirm npm
sudo pacman -S --noconfirm rustup

sudo npm install -g yarn
sudo npm install -g ember-cli

# TeX Stuff
sudo pacman -S --noconfirm pandoc pandoc-citeproc
sudo pacman -S --noconfirm texlive-core texlive-localmanager-git
sudo pacman -S --noconfirm biber
