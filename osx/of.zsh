# Core (Don't use Apple's version)
brew install git
brew install watchman
brew install docker
brew install kubectl
brew install act

# Cask
brew install --cask visual-studio-code
brew install --cask tuple


# Other
function init_nvm() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
}

function init_keygen(){
  ssh-keygen -t ed25519 -C 'jweinbender@obama.org'
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
}

function init_git(){
  git config --global user.name "Jack Weinbender"
  git config --global user.email "jweinbender@obama.org"
}

init_git
init_keygen
init_nvm