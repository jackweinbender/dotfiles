#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Setup SSH Keys
ssh-keygen -t rsa -b 4096 -C "jack.weinbender@gmail.com"

# Enable non-standard inputs
gsettings set org.gnome.desktop.input-sources show-all-sources true

source pacman.sh
source dev.sh
source tex-pandoc.sh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Link Symlinks
source ../symlinks.sh