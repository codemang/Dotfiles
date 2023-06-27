# Needed for Vint
# https://github.com/Vimjas/vint
export PATH=$PATH:/Users/nate/Library/Python/3.10/bin/

alias vim="nvim"
alias v="nvim"
alias zpref="nvim ~/.zshrc"

# Toggle between vim and shell with ctrl-z
function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

function bind-ctrl-z() {
  zle -N fancy-ctrl-z
  bindkey '^Z' fancy-ctrl-z
}

function toggleColorscheme() {
  ruby ~/Dotfiles/util/toggle_colors.rb
}

function isLightTheme() {
  if [ ! -f ~/.color-scheme-env ]; then
    echo "light"
  else
    head -n 1 ~/.color-scheme-env
  fi
}

alias tc="toggleColorscheme"

if [ "$SHELL" = "/bin/zsh" ]; then
  bind-ctrl-z
fi

