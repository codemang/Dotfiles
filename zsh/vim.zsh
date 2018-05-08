alias vim="nv"
alias v="nv"
alias vimrc="nv ~/.vimrc"
alias zpref="nv ~/.zshrc"

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

function nv() {
  random_pid=${RANDOM}
  echo "\n$random_pid\n" >> ~/.nvim-trackers
  NVIM_LISTEN_ADDRESS=/tmp/nvim-${random_pid} nvim $*
}
