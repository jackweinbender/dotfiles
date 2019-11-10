#!/usr/bin/env bash

# Install Essentials for completion
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm zsh

# Screen Sharing Setup
sudo pacman -S --noconfirm vino
  ## Allows Win/Mac ScreenShareing
  gsettings set org.gnome.Vino require-encryption false

# GUI Utils
sudo pacman -S --noconfirm chromium
sudo pacman -S --noconfirm firefox
sudo pacman -S --noconfirm conky

# AUR packages
yay -S --noconfirm dropbox
yay -S --noconfirm zoom
yay -S --noconfirm slack-desktop