#!/usr/bin/env bash

rm -rf $HOME/.gitconfig \
       $HOME/.zshrc \
       $HOME/.oh-my-zsh/themes/jack.zsh-theme \
       $HOME/.conkyrc \
       $HOME/.config/autostart/conky.desktop


# .gitconfig
ln -s $HOME/.dotfiles/symlinks/.gitconfig $HOME/.gitconfig

# .zshrc
ln -s $HOME/.dotfiles/symlinks/.zshrc $HOME/.zshrc

# jack.zsh-theme
ln -s $HOME/.dotfiles/symlinks/jack.zsh-theme $HOME/.oh-my-zsh/themes/jack.zsh-theme

# Conky dotfile
ln -s $HOME/.dotfiles/arch/.conkyrc $HOME/.conkyrc

# Tmux Conf
ln -s $HOME/.dotfiles/symlinks/tmux.conf $HOME/.tmux.conf

# Autostart Scipts
ln -s $HOME/.dotfiles/arch/autostart/conky.desktop $HOME/.config/autostart/conky.desktop