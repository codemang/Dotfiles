# -L follows symlinks
export FZF_DEFAULT_COMMAND='rg --files -L'
export FZF_DEFAULT_OPTS='--height 80%'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Fuzzy find tmux sessions.
# Bound to ctrl-u in the iTerm settings.
tzf() {
  all_tmux_sessions=$(tmux ls -F "#{session_name}")
  chosen_tmux_session=$(printf "${all_tmux_sessions[@]}" | fzf)
  # chosen_tmux_session=$("${all_tmux_sessions[@]}" | fzf)
  tmux switch -t $chosen_tmux_session
}

source "$HOME/.fzf.zsh"
