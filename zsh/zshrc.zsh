#! /bin/zsh

# Initialize Autocomplete
autoload -Uz compinit && compinit

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats '/%b/'

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# Autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward # up
bindkey '\e[B' history-search-forward  # down

# NO BEEP
setopt NO_BEEP 

# Set up the prompt
setopt PROMPT_SUBST

PROMPT='%F{green}%n%f 𐤀 %F{cyan}%m%f ${vcs_info_msg_0_}
%F{245}%2~%f %F{yellow}% » %f'
