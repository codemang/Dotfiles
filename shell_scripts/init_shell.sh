#!/bin/bash

# Set global ENV vars.
export DOTFILES=$HOME/Dotfiles
export EDITOR=nvim

[ -f ~/.before_init_private_scripts.sh ] && source ~/.before_init_private_scripts.sh
# Helper aliases/functions
source $DOTFILES/zsh/git.zsh
source $DOTFILES/zsh/tmux.zsh
source $DOTFILES/zsh/vim.zsh
source $DOTFILES/zsh/z.zsh
source $DOTFILES/zsh/fzf.zsh
source $DOTFILES/zsh/docker.zsh
source $DOTFILES/zsh/heroku.zsh
source $DOTFILES/shell_scripts/notes.sh
source $DOTFILES/zsh/misc.zsh

[ -f ~/.private_scripts.zsh ] && source ~/.private_scripts.zsh
