#! /bin/zsh

info "Generating ~/.tmux.conf ..."

# Create the template local file to ~/.zshrc
cat <<EOM >"$HOME/.tmux.conf"
# ---
# TMUX file for $USER@$(hostname) 
# Generated on: $(date +%F)
# ---

EOM

cat $DOTFILES/tmux/tmux.conf >>"$HOME/.tmux.conf"

success "Done."
