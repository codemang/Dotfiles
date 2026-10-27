export EDITOR=nvim

# Commands installed per user: mise (its Linux installer puts it here) and the
# links bootstrap_v2's dotfiles step makes, like tmux_switch_session.
export PATH="$HOME/.local/bin:$PATH"

# Node, Ruby and Python versions
source $DOTFILES/shell_scripts/mise.sh

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
