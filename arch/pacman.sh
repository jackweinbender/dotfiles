#!/usr/bin/env bash

# Install Essentials for completion
sudo pacman -S --noconfirm pacaur
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm zsh

# Screen Sharing Setup
sudo pacman -S --noconfirm vino
  ## Allows Win/Mac ScreenShareing
  gsettings set org.gnome.Vino require-encryption false

# GUI Utils
sudo pacman -S --noconfirm chromium
sudo pacman -S --noconfirm firefox
sudo pacman -S --noconfirm dropbox
sudo pacman -S --noconfirm conky

# Pacaur
pacaur -S --noconfirm --noedit zoom
pacaur -S --noconfirm --noedit slack-desktop