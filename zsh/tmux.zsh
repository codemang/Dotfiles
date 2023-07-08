alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tpref="vim ~/.tmux.conf"
alias tsource="tmux source-file $HOME/.tmux.conf"
alias tls="tmux list-sessions"
alias ts="tmux switch -t"
alias td="tmux detach"
alias tk="tmux kill-session -t"
alias tname="tmux display-message -p '#S'"
alias rtmux="tmux kill-server"
alias mux="tmuxinator"

function tdev() {
  mux start dev $*
}
