# Add local bin directory to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add custom bin directory to PATH
export PATH="$DOTFILES/bin:$PATH"

# Add Rust/Cargo bin directory to PATH if installed (keg-only homebrew install)
[[ -d "/opt/homebrew/opt/rustup/bin" ]] && export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# Go environment setup
if command -v go >/dev/null 2>&1; then
  # Add GOPATH variable for convenience
  export GOPATH=$(go env GOPATH)
  # Add Go binaries to PATH
  export PATH="$PATH:$GOPATH/bin"
fi

# Initialize rbenv if installed
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi
