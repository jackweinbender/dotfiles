# Pandoc
sudo pacman -S --noconfirm pandoc pandoc-citeproc

# TeX Stuff
sudo pacman -S --noconfirm \
    texlive-core \
    texlive-latexextra \
    texlive-bibtexextra
sudo pacman -S --noconfirm biber
yay -S --noconfirm texlive-localmanager-git

# My Pandoc and CSL Settings
git clone https://github.com/jackweinbender/dot-pandoc.git ~/.pandoc
git clone https://github.com/jackweinbender/dot-csl.git ~/.csl