source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# VOLTA_FEATURE_PNPM-start
export VOLTA_FEATURE_PNPM=1
# VOLTA_FEATURE_PNPM-end

export CERT_PATH='/Users/jack.weinbender/.ca_certs/ZscalerRootCertificate-2048-SHA256.pem'
export CERT_DIR='/Users/jack.weinbender/.ca_certs'
export SSL_CERT_FILE='/Users/jack.weinbender/.ca_certs/ZscalerRootCertificate-2048-SHA256.pem'
export SSL_CERT_DIR='/Users/jack.weinbender/.ca_certs'
export NODE_EXTRA_CA_CERTS='/Users/jack.weinbender/.ca_certs/ZscalerRootCertificate-2048-SHA256.pem'
export HTTPS_CA_DIR='/Users/jack.weinbender/.ca_certs'
