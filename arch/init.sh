#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Setup SSH Keys
ssh-keygen -t rsa -b 4096 -C "jack.weinbender@gmail.com"

# Update OS
sudo pacman -Syyu

# Install yay
## Install yay for AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../
rm -rf yay

# Add my stuff
source pacman.sh
source dev.sh
# source tex-pandoc.sh
source fonts.sh

# Link Symlinks
source symlinks.sh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
