#!/bin/bash

destination_file=""

if test -f ~/.zshrc; then
    destination_file=~/.zshrc
elif test -f ~/.bashrc; then
    destination_file=~/.bashrc
fi

source_init_shell_cmd="source ~/Dotfiles/shell_scripts/init_shell.sh"

if ! grep -q  "$source_init_shell_cmd" $destination_file; then
  echo $source_init_shell_cmd >> $destination_file
fi

