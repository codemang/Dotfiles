plugins=(bundler osx rake ruby rails gem brew zsh-completions)
autoload -U compinit -u && compinit -u

setopt CORRECT
unsetopt inc_append_history
unsetopt share_history

# Colors when listing
export LD_BIND_NOW=1
export CLICOLOR=1
export LSCOLORS=GxBxhxDxfxhxhxhxhxcxcx

# Colors when using tab-completion in the command line
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Enable zsh syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
