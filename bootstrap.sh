#! /bin/zsh

# Need these helpers to be required so we can get the pretty output
function bootstrap_init {
  source zsh/lib/helpers.zsh
}

bootstrap_init
source zsh/bootstrap.zsh
