function build_from_git()
{
  clone $1
  build_package $1
  cleanup_package $1
}

function clone()
{
  echo "Cloning $1 from aur.archlinux.org..."
  git clone --quiet --depth 1 https://aur.archlinux.org/${1}.git && \
  echo "Done"
}

function build_package()
{
  cd $1 && makepkg -si --noconfirm
  cd ../
}

function cleanup_package()
{
  rm -rf $1
}
