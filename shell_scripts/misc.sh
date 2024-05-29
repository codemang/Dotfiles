# RipGrep config file.
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Start SSH agent
eval `ssh-agent` > /dev/null

# Initialize brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Update ls colors
eval "$(dircolors ~/Dotfiles/dotfiles/dir_colors)"

export PATH=$PATH:/usr/local/go/bin

export WDIR=/mnt/c/Users/$USER
alias src="source ~/.bashrc"
alias bpref="vim ~/Dotfiles/shell_scripts/wsl_bashrc.sh"
alias cdc="cd $WDIR"

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

# Bind ctrl-v to fuzzy-find over changed files in Git.
bind '"\C-v":"$(fuzzy_find_directories)\015"'
