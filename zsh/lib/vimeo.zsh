source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# VOLTA_FEATURE_PNPM-start
export VOLTA_FEATURE_PNPM=1
# VOLTA_FEATURE_PNPM-end
