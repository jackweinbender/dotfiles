#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install the basics
source ~/.dotfiles/apt.sh

# Setup Symlinks
source ~/.dotfiles/symlinks/init.sh

# Setup Terminal
source ~/.dotfiles/terminal/init.sh

# Kill Terminal to force Restart
echo "\n\n\nReopen Terminal when this window closes in 10 sec"

sleep 10s

killall "Terminal" &> /dev/null
