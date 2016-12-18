#!/usr/bin/env bash

brew install zsh zsh-completions

sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh

echo "Restart Terminal, then run zim.sh"
