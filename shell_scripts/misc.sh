# RipGrep config file.
export RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# Start SSH agent
eval `ssh-agent` > /dev/null

# Initialize brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Update ls colors
eval "$(dircolors ~/Dotfiles/dotfiles/dir_colors)"

export PATH=$PATH:/usr/local/go/bin

export WDIR=/mnt/c/Users/nrubin19
alias src="source ~/.bashrc"
alias bpref="vim ~/Dotfiles/shell_scripts/wsl_bashrc.sh"
alias cdc="cd $WDIR"
