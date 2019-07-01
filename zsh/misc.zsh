# LS SHORTCUTS
alias ls="ls -G"
alias la="ls -A"
alias ll="ls -l -h"
alias lla="ls -al"
alias lal="ls -al"
alias lh="ls -d .??*"
alias llh="ls -ld -h  .??*"
alias lhl="ls -ld -h .??*"
alias ld="ls -d */" # Show directories
alias lg="ls | grep"
alias le="find . -maxdepth 1  -type f -perm -u=x" # Show executables
alias lf="ls | egrep -v '^d'"
alias clr="clear"

# MISCELLENEOUS SHORTCUTS
alias unsu="sudo -k;"
alias su="sudo -s"
alias sub="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias src="source ~/.zshrc"
alias serv="python -m SimpleHTTPServer 8000"
alias ecron="env EDITOR=nvim crontab -e"
alias mem="top -l 1 | ag Phys"
alias notifyDone='reattach-to-user-namespace terminal-notifier -title "Hey Nate" -message "Done with task!"'
alias zprompt="vim ~/Dotfiles/zsh/zshrc_prompt"
alias findp="ps aux | grep"
alias pbc="pbcopy"

alias dl="cd ~/Downloads"

# Colorized man pages
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
}

# Redo last command in sudo
function fuck() {
  last_cmd=$(fc -ln | tail -2 | tail -1)
  echo "Going to execute: sudo $last_cmd"
  eval "sudo $last_cmd"
}

function load_ssh() {
  ssh-add ~/.ssh/id_rsa_codemang
}

alias serv="python -m SimpleHTTPServer 8000"

# SSH without italics
alias ssh="TERM=xterm-256color ssh "

# Helper functions for pull request utility script
function open_prs() {
  ruby $DOTFILES/util/track_pull_request_reviews.rb open $*
}

function list_prs() {
  ruby $DOTFILES/util/track_pull_request_reviews.rb list
}

function notify_prs() {
  ruby $DOTFILES/util/track_pull_request_reviews.rb notify
}

function orats_console() {
  docker-compose exec  website /bin/sh
}

function site() {
  port=
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome $(docker-machine ip default):${1:-3000}
}
