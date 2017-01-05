#!/usr/bin/env bash

# Add PPAs
sudo add-apt-repository ppa:webupd8team/atom

# Update apt
sudo apt-get update

# Upgrade All
sudo apt-get upgrade

# CLI Tools
sudo apt-get install git
sudo apt-get install vim

# Dev Env
sudo apt-get install node
sudo apt-get install elixir
sudo apt-get install pandoc
sudo apt-get install rust

# Terminal Deps
sudo apt-get install zsh

# GUI Apps
sudo apt-get install chromium
sudo apt-get install atom
sudo apt-get install dropbox
sudo apt-get install google-drive
sudo apt-get install transmission

# Remove outdated versions from apt.
sudo apt-get clean
