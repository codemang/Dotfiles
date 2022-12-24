alias vim="nvim"
alias v="nvim"
alias zpref="nvim ~/.zshrc"

# Toggle between vim and shell with ctrl-z
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

function toggleColorscheme() {
  ruby ~/Dotfiles/util/toggle_colors.rb
}

alias tc="toggleColorscheme"

function isLightTheme() {
  if [ ! -f ~/.color-scheme-env ]; then
    echo "light"
  else
    head -n 1 ~/.color-scheme-env
  fi
}
