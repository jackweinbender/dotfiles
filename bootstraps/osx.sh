#! /bin/zsh

# Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install core utils:
brew install \
  git \
  zsh

# Clone this repo into the user's HOME dir
git clone git@github.com:jackweinbender/dotfiles.git $HOME/.dotfiles
