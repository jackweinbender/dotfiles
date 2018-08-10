#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Setup SSH Key
ssh-keygen -t rsa -b 4096 -C "jack.weinbender@gmail.com"

# Install the basics (Required)
source ~/.dotfiles/homebrew.sh

# Setup Symlinks (Required)
source ~/.dotfiles/osx/symlinks.sh

# Install Dev Tools
# source ~/.dotfiles/development.sh

# Install Dissertation Stuff
# source ~/.dotfiles/dissertation.sh

# Setup Terminal (Required)
source ~/.dotfiles/oh-my-zsh/init.sh

# Kill Terminal to force Restart
echo "\n\n\nReopen Terminal when this window closes in 10 sec"

sleep 10s

killall "Terminal" &> /dev/null
