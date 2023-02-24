#!/usr/bin/env zsh

# Default key
ssh-keygen -t ed25519 -C 'jack@weinbender.io'
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
