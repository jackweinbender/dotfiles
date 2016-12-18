#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.hs` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install the basics
source homebrew.sh

# Setup Symlinks
source symlinks/init.sh

# Setup Terminal
source terminal/init.sh

# Kill Terminal to force Restart
echo "\n\n\nReopen Terminal when this window closes"

sleep 5s

killall "Terminal" &> /dev/null
