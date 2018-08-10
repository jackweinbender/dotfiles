# My Pandoc and CSL Settings
brew install pandoc pandoc-citeproc
git clone https://github.com/jackweinbender/dot-pandoc.git ~/.pandoc
git clone https://github.com/jackweinbender/dot-csl.git ~/.csl

mkdir -p ~/Projects
mkdir -p ~/Library/texmf/tex/latex
git clone https://github.com/jackweinbender/utexas-dissertation.git ~/Projects/utexas-dissertation
ln -s ~/Projects/utexas-dissertation ~/Library/texmf/tex/latex/utexas-dissertation

brew cask install typora
brew cask install texpad
brew cask install google-cloud-sdk
brew cask install libreoffice
brew cask install mactex