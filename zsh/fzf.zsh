# -L follows symlinks
export FZF_DEFAULT_COMMAND='rg --files -L'
export FZF_DEFAULT_OPTS='--height 80%'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Bind ctrl-g to search over changed files in Git.
# https://stackoverflow.com/a/51439945
case "$(uname -sr)" in
  Linux*)
    # Bind ctrl-g to fuzzy-find over changed files in Git.
    bind '"\C-g":"$(gcf | fzf)\015"'

    # Bind ctrl-g to fuzzy-find over Git branches.
    bind '"\C-b":"$(fuzzy_find_branches)\015"'
    ;;
  Darwin*) # Mac
    # Set in iTerm preferences
    ;;
esac

# Fuzzy find tmux sessions.
# Bound to ctrl-u in the iTerm settings.
tzf() {
  all_tmux_sessions=$(tmux ls -F "#{session_name}")
  chosen_tmux_session=$(printf "${all_tmux_sessions[@]}" | fzf)
  # chosen_tmux_session=$("${all_tmux_sessions[@]}" | fzf)
  tmux switch -t $chosen_tmux_session
}

[ -f  $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
