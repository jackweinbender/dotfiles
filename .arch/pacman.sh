#!/usr/bin/env bash

# Install Zsh and git
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm zsh
sudo pacman -S --noconfirm pacaur

# Screen Sharing Setup
sudo pacman -S --noconfirm vino
  ## Allows Win/Mac ScreenShareing
  gsettings set org.gnome.Vino require-encryption false

# GUI Utils
sudo pacman -S --noconfirm chromium
sudo pacman -S --noconfirm firefox
sudo pacman -S --noconfirm dropbox
sudo pacman -S --noconfirm lastpass

sudo pacaur -S --noconfirm zoom
