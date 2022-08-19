alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tpref="vim ~/.tmux.conf"
alias tsource="tmux source-file $HOME/.tmux.conf"
alias tls="tmux list-sessions"
alias ts="tmux switch -t"
alias td="tmux detach"
alias tk="tmux kill-session -t"
alias tname="tmux display-message -p '#S'"
alias restart_tmux="tmux kill-server"

function lay() {
  tmux split-window -h
  tmux split-window -v
  tmux split-window -h
  tmux select-pane -t 2
  tmux split-window -h
  tmux select-pane -t 1
  tmux split-window -h
}
