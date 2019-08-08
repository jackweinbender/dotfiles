# Development

# Code Editors
sudo pacman -S --noconfirm gconf
pacaur -S --noconfirm --noedit code
sudo pacman -S --noconfirm vim

## Virtualbox
sudo pacman -S --noconfirm linux-headers
sudo pacman -S --noconfirm vagrant
sudo pacman -S --noconfirm virtualbox
  ## These are required for Arch, they replace the DKMS packages
  sudo pacman -S --noconfirm virtualbox-host-modules-arch
  sudo pacman -S --noconfirm virtualbox-guest-modules-arch

## Docker
sudo pacman -S --noconfirm docker
sudo pacman -S --noconfirm docker-compose
sudo pacman -S --noconfirm docker-machine

sudo usermod -aG docker ${USER}
sudo systemctl enable docker.service

## Web & Node
sudo pacman -S --noconfirm nodejs

## Rust
sudo pacman -S --noconfirm rustup

## Ruby
pacaur -S --noconfirm --noedit rbenv
pacaur -S --noconfirm --noedit ruby-build

# Google Cloud SDK
pacaur -S --noconfirm --noedit google-cloud-sdk
