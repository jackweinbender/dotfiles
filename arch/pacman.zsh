#!/bin/zsh

# GUI Utils
sudo pacman -S --noconfirm brave
sudo pacman -S --noconfirm chromium
sudo pacman -S --noconfirm firefox

# Editors
sudo pacman -S --noconfirm gconf
yay -S --noconfirm code
sudo pacman -S --noconfirm vim

## Docker
sudo pacman -S --noconfirm docker
sudo pacman -S --noconfirm docker-compose
sudo pacman -S --noconfirm docker-machine

sudo usermod -aG docker ${USER}
sudo systemctl enable docker.service

## Node
sudo pacman -S --noconfirm nodejs
sudo pacman -S --noconfirm npm

## Rust
sudo pacman -S --noconfirm rustup

## Ruby
yay -S --noconfirm rbenv
yay -S --noconfirm ruby-build
