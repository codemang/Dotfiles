export EDITOR=nvim

# Commands installed per user: mise (its Linux installer puts it here) and the
# links bootstrap's dotfiles step makes, like tmux_switch_session.
export PATH="$HOME/.local/bin:$PATH"

# Node, Ruby and Python versions
source $DOTFILES/dotfiles/shell_scripts/mise.sh

# Helper aliases/functions
source $DOTFILES/dotfiles/shell_scripts/git.sh
source $DOTFILES/dotfiles/shell_scripts/github.sh
source $DOTFILES/dotfiles/shell_scripts/tmux.sh
source $DOTFILES/dotfiles/shell_scripts/herdr.sh
source $DOTFILES/dotfiles/shell_scripts/vim.sh
source $DOTFILES/dotfiles/shell_scripts/z.sh
source $DOTFILES/dotfiles/shell_scripts/fzf.sh
source $DOTFILES/dotfiles/shell_scripts/docker.sh
source $DOTFILES/dotfiles/shell_scripts/notes.sh
source $DOTFILES/dotfiles/shell_scripts/misc.sh

# Allow certain utils to be called with no path, e.g `claude_notif`
export PATH=$PATH:$DOTFILES/util
