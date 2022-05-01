# Follows the guide accessed May 1, 2022
# https://forum.endeavouros.com/t/linux-gaming-guide/7339#heading--linux-gaming-steam

## Vulkan Packages
sudo pacman -S \
  vulkan-icd-loader \
  lib32-vulkan-icd-loader

## Radeon-Specific packages for my card.
## See the guide for updates
sudo pacman -S \
  vulkan-radeon \
  lib32-vulkan-radeon

# Launcher / Platforms(s)
sudo pacman -S \
  steam
