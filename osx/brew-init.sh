#!/usr/bin/env bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrew Config
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
source $HOME/.zprofile
