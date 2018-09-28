#!/usr/bin/env bash

rm -rf $HOME/.gitconfig $HOME/.zshrc $HOME/.oh-my-zsh/themes/jack.zsh-theme

# .gitconfig
ln -s $HOME/.dotfiles/symlinks/.gitconfig $HOME/.gitconfig

# .zshrc
ln $HOME/.dotfiles/symlinks/.zshrc $HOME/.zshrc

# jack.zsh-theme
ln -s $HOME/.dotfiles/symlinks/jack.zsh-theme $HOME/.oh-my-zsh/themes/jack.zsh-theme
