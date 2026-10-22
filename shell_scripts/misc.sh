# RipGrep config file.
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Start SSH agent
eval `ssh-agent` > /dev/null

# LS SHORTCUTS
alias ls="ls -G --color=auto"
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
if [ -f ~/.zshrc ]; then
  alias src="source ~/.zshrc"
elif [ -f ~/.bashrc ]; then
  alias src="source ~/.bashrc"
fi
alias serv="python -m SimpleHTTPServer 8000"
alias ecron="env EDITOR=nvim crontab -e"
alias mem="top -l 1 | ag Phys"
alias notifyDone='reattach-to-user-namespace terminal-notifier -title "Hey Nate" -message "Done with task!"'
alias zprompt="vim $DOTFILES/shell_scripts/zshrc_prompt"
alias findp="ps aux | grep"
alias dl="cd ~/Downloads"
alias ssha="ssh-add ~/.ssh/id_rsa_github"

# Linux
case "$(uname -sr)" in Linux*)
    # Copy clipboard
    alias ccb="win32yank.exe -i"
    # Paste clipboard
    alias pcb="win32yank.exe -o --lf"
esac

# Mac
case "$(uname -sr)" in Darwin*)
    # Copy clipboard
    alias pcb="pbpaste"
    # Paste clipboard
    alias ccb="pbcopy"
esac

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

# SSH without italics
alias ssh="TERM=xterm-256color ssh "

# E.g getRequest localhost:3006/api/v1/listings/search
function getRequest() {
  curl -i -H "Accept: application/json" $1
}

# E.g postRequest localhost:3006/webhooks/twilio-incoming-sms-message '{"messageBody": "Hi"}'
function postRequest() {
  curl \
    -i \
    -v \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -X POST \
    $1
}

case "$(uname -s)" in
    Linux*) # Linux
        alias ccb="xclip -selection clipboard" # Copy clipboard
        alias pcb="xclip -o -selection clipboard" # Paste clipboard
        # Turn on colors for ls
        eval "$(dircolors -b $DOTFILES/dotfiles/dir_colors)" # Update ls colors
        ;;

    Darwin*) # OSX
        alias ccb="pbcopy" # Copy clipboard
        alias pcb="pbpaste" # Paste clipboard
        ;;
esac

lsync_dir() {
  folder=${PWD##*/}
  lsyncd -nodaemon -delay 1 -rsyncssh $PWD nrubin19@tscgwd-rr-880 /home/nrubin19/$folder
}

view_csv() {
  cat $1 | sed 's/,/ ,/g' | column -t -s, | less -S
}

jqc() {
  pcb | jq
}

fuzzy_find_directories() {
  find * -type d | fzf
}

list_to_comma_separated() {
  paste -s -d, -
}
