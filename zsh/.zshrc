# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set the current dir to the ZSH_CUSTOM path
ZSH_CUSTOM="$(dirname $(readlink -f $0))"
ZSH_THEME="jack"

plugins=(git)

source $ZSH/oh-my-zsh.sh