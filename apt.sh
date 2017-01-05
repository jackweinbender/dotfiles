#!/usr/bin/env bash

# Add PPAs
add-apt-repository ppa:webupd8team/atom

# Update apt
apt-get update

# Upgrade All
apt-get upgrade

# CLI Tools
apt-get install git
apt-get install vim

# Dev Env
apt-get install node
apt-get install elixir
apt-get install pandoc
apt-get install rust

# Terminal Deps
apt-get install zsh

# GUI Apps
apt-get install chromium
apt-get install atom
apt-get install dropbox
apt-get install google-drive
apt-get install transmission

# Remove outdated versions from apt.
apt-get clean
