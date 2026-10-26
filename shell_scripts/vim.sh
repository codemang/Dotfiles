#!/bin/bash

export EDITOR='nvim'
export VISUAL='nvim'
alias vim=nvim
alias v=nvim

vdot() {
  file=$(ls ~/Dotfiles/shell_scripts/ | fzf)
  vim ~/Dotfiles/shell_scripts/$file
}

function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

function bind-ctrl-z() {
  zle -N fancy-ctrl-z
  bindkey '^Z' fancy-ctrl-z
}

# Toggle back into Neovim with Ctrl+Z
# The running shell, not $SHELL (the login shell): bash can run under a zsh login.
if [ -n "$ZSH_VERSION" ]; then
  bind-ctrl-z
else
  if [[ $- == *i* ]]; then
    stty susp undef
    bind '"\C-z":"fg\n"'
  fi
fi

# Cycle iTerm and Neovim through color schemes.
alias tc="$DOTFILES/util/toggle_colors.sh"
