#!/bin/bash

# Add a command to source my shell initializer script to the existing
# initializer script (e.g .bashrc, .zshrc, etc)
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

# Remove the default 'custom' folder from nvchad and symlink my personal folder.
rm -rf ~/.config/nvim/lua/custom
ln -s ~/Dotfiles/vim/ ~/.config/nvim/lua/custom
