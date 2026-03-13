# README / ZSH

Sourcing the `zsh/boostrap.zsh` file will overwrite your current `.zshrc` file.

Placing any `*.zsh` file into the `/zsh/lib` folder will cause it to be added to the list of sources on the newly generated `.zshrc`.

A `lib/.local.zsh` file may be used to include machine-specific configurations
and overrides that you do not wish to be committed to version control. Don't
put secrets in there.

After making any changes, run `$ zsh_init` to run this script and reload the session.
