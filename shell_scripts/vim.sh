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
if [ "$SHELL" = "/bin/zsh" ]; then
  bind-ctrl-z
else
  if [[ $- == *i* ]]; then
    stty susp undef
    bind '"\C-z":"fg\n"'
  fi
fi

function toggleColorscheme() {
  ruby ~/Dotfiles/util/toggle_colors.rb
}

function isLightTheme() {
  if [ ! -f ~/.color-scheme-env ]; then
    echo "light"
  else
    head -n 1 ~/.color-scheme-env
  fi
}

alias tc="toggleColorscheme"
