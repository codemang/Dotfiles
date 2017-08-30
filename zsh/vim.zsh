alias vim="mvim -v"
alias v="vim"
alias vimrc="vim ~/.vimrc"
alias zpref="vim ~/.zshrc"

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
