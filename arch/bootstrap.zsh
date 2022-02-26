source helpers.zsh

# Update OS
sudo pacman -Syyu

# Install yay
pacman -S --needed git base-devel && install_from_git yay

source pacman.zsh
source keygen.zsh
