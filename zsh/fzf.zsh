source "$HOME/.fzf.zsh"
# -L follows symlinks
export FZF_DEFAULT_COMMAND='rg --files -L'
export FZF_DEFAULT_OPTS='--height 80%'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
