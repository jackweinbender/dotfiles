#! /bin/zsh

# This init script assumes that zsh has already been installed.
# As of Sept. 2021, zsh is installed by default in MacOS, but
# for other OSes, you may need to install it first using the
# appropriate package manager.

# Git is not installed by default in MacOS

# REQUIREMENTS
# 1. git
# 2. zsh

info "Generating ~/.zshrc ..."

# Create the template local file to ~/.zshrc
cat <<EOM >"$HOME/.zshrc"
#! /bin/zsh

# ---
# ZSHRC file for $USER@$(hostname) 
# Generated on: $(date +%F)
# ---

EOM

# Bootstrap variables
DOTFILES="$(dirname "${0:a:h}")"

# Export the base DOTFILES variable
cat <<EOM >>~/.zshrc
# Path for the "dotfiles" (defaults to ~/dotfiles)
export DOTFILES=${HOME}/.dotfiles

EOM

# Pull in the shared .zshrc file
cat <<EOM >>~/.zshrc
# include the base .zshrc file from this repo as well as
# all of the helper files in the \`zsh/lib\` dir

EOM

for file in $DOTFILES/zsh/lib/**/*.zsh; do
  echo "source $file" >>~/.zshrc
done

success "Done."
