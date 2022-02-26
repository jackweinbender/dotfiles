# Update OS
sudo pacman -Syyu

# Install yay
pacman -S --needed git base-devel && install_from_git yay

function install_from_git()
{
  git clone https://aur.archlinux.org/${1}.git
  cd $1
  makepkg -si --noconfirm
  cd ../ && rm -rf $1
}
