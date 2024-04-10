#!/bin/bash

export EDITOR='nvim'
export VISUAL='nvim'
alias vim=nvim
alias v=nvim

vdot() {
  file=$(ls ~/Dotfiles/shell_scripts/ | fzf)
  vim ~/Dotfiles/shell_scripts/$file
}
