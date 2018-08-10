#!/usr/bin/env bash

rm -rf ~/.gitconfig ~/.zshrc ~/.oh-my-zsh/themes/jack.zsh-theme

# .gitconfig
ln -s ~/.dotfiles/symlinks/.gitconfig ~/.gitconfig

# .zshrc
ln ~/.dotfiles/symlinks/.zshrc ~/.zshrc

# jack.zsh-theme
ln -s ~/.dotfiles/symlinks/jack.zsh-theme ~/.oh-my-zsh/themes/jack.zsh-theme
