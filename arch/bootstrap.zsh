# Update OS
sudo pacman -Syyu
sudo pacman -S base-devel

pacman -S --needed git base-devel && install_from_git yay

function install_from_git()
{
  git clone https://aur.archlinux.org/${1}.git
  cd $1
  makepkg -si --noconfirm
  cd ../ && rm -rf $1
}


