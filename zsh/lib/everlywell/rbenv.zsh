# Note issues with M1 macs and older versions of Ruby:
# https://stackoverflow.com/questions/69012676/install-older-ruby-versions-on-a-m1-macbook

# First run:
# brew uninstall --ignore-dependencies readline
# brew uninstall --ignore-dependencies openssl
# brew uninstall --ignore-dependencies ruby-build
# rm -rf /opt/homebrew/etc/openssl@1.1
# brew install -s readline
# brew install -s openssl
# brew install -s ruby-build

export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export LDFLAGS="-L/opt/homebrew/opt/readline/lib:$LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/readline/include:$CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/readline/lib/pkgconfig:$PKG_CONFIG_PATH"
export optflags="-Wno-error=implicit-function-declaration"
export LDFLAGS="-L/opt/homebrew/opt/libffi/lib:$LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/libffi/include:$CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"