# Repo root, found by following the ~/.zshrc symlink back to this file.
export EDITOR=nvim

# Language initializers
source $DOTFILES/shell_scripts/node.sh
source $DOTFILES/shell_scripts/ruby.sh

# Helper aliases/functions
source $DOTFILES/shell_scripts/git.sh
source $DOTFILES/shell_scripts/tmux.sh
source $DOTFILES/shell_scripts/herdr.sh
source $DOTFILES/shell_scripts/vim.sh
source $DOTFILES/shell_scripts/z.sh
source $DOTFILES/shell_scripts/fzf.sh
source $DOTFILES/shell_scripts/docker.sh
source $DOTFILES/shell_scripts/notes.sh
source $DOTFILES/shell_scripts/misc.sh

# Allow certain utils to be called with no path, e.g `claude_notif`
export PATH=$PATH:$DOTFILES/util
