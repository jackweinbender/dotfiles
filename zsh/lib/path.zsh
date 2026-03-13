# Add custom bin directory to PATH
export PATH="$DOTFILES/bin:$PATH"

# Add Rust/Cargo bin directory to PATH if installed
if command -v cargo &> /dev/null; then
  export PATH=~/.cargo/bin:$PATH
fi

# Go environment setup
if command -v go >/dev/null 2>&1; then
  # Add GOPATH variable for convenience
  export GOPATH=$(go env GOPATH)
  # Add Go binaries to PATH
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# Initialize rbenv if installed
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi
