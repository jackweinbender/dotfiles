# Development

# Code Editors
pacaur -S --noconfirm visual-studio-code
pacman -S --noconfirm vim

## Virtualbox
sudo pacman -S --noconfirm virtualbox
  sudo pacman -S --noconfirm virtualbox-host-modules-arch
  ### This is specifically for the LTS install of Arch use 'linux-headers'
  ### if you aren't using the LTS install.
  sudo pacman -S --noconfirm linux-lts-headers
sudo pacman -S --noconfirm vagrant

## Web & Node
sudo pacman -S --noconfirm nodejs
sudo pacman -S --noconfirm yarn
  ### Ember
  sudo npm install -g ember-cli

## Rust
sudo pacman -S --noconfirm rustup

## Ruby
sudo pacaur -S --noconfirm rbenv
sudo pacaur -S --noconfirm ruby-build

# Google Cloud SDK
pacaur -S --noconfirm google-cloud-sdk