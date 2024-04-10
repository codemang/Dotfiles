#!/bin/bash

# Create a new tmux session.
alias tn="tmux new -s"

# Attach to an existing tmux session.
alias ta="tmux attach -t"

# List available tmux sessions.
alias tls="tmux list-sessions"

# Detach from the current tmux session.
alias td="tmux detach"

# Delete/kill a tmux session.
alias tk="tmux kill-session -t"

# Print name of current tmux session.
alias tname="tmux display-message -p '#S'"

# Kill all tmux sessions and restart the process.
alias rtmux="tmux kill-server"

# If opening a new pane in TMUX, don't change to the home directory, but open
# all new terminals in the home directory.
if [ ! $TMUX ]; then
  cd ~
fi

alias mux=tmuxinator

# Start a tmux session with our preferred layout. By default, it will name the
# session after the current directory, but you can add an optional CLI arg to
# change the name.
tdev() {
  mux start dev $*
}

