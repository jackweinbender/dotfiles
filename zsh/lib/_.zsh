function zsh_init() {
  source $DOTFILES/zsh/bootstrap.zsh
  source $HOME/.zprofile
  source $HOME/.zshrc
}

# Reload the agents topic: recompile ~/Code config and relink skills.
# Run in a subshell — the bootstrap touches nothing in the live shell
# (skills/bin is already on PATH, skills are symlinked live), so there's
# no reason to pollute it with the bootstrap's internals.
function agents_init() {
  zsh $DOTFILES/agents/bootstrap.zsh
}
