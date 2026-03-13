# Default key generation for new machines.
# I can never remember the exact command.
ssh-keygen -t ed25519 -C 'jack@weinbender.io'
ssh-add ~/.ssh/id_ed25519
