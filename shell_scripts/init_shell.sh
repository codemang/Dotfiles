#!/bin/bash

# Set global ENV vars.
export DOTFILES=$HOME/Dotfiles
export EDITOR=nvim

[ -f ~/.before_init_private_scripts.sh ] && source ~/.before_init_private_scripts.sh
# Helper aliases/functions
source $DOTFILES/shell_scripts/git.sh
source $DOTFILES/shell_scripts/tmux.sh
source $DOTFILES/shell_scripts/vim.sh
source $DOTFILES/shell_scripts/z.sh
source $DOTFILES/shell_scripts/fzf.sh
source $DOTFILES/shell_scripts/docker.sh
source $DOTFILES/shell_scripts/notes.sh
source $DOTFILES/shell_scripts/misc.sh

[ -f ~/.private_scripts.zsh ] && source ~/.private_scripts.zsh
