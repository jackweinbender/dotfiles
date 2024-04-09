#! /bin/zsh

function bootstrap_init() {
  # Need these helpers to be required so we can get the pretty output on the 
  # first go-round
  source zsh/lib/color_helpers.zsh
  source zsh/lib/output_helpers.zsh
}

bootstrap_init
source zsh/bootstrap.zsh
