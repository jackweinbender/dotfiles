# Update OS
sudo pacman -Syyu
sudo pacman -S base-devel

# Install yay
## Install yay for AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ../
rm -rf yay
