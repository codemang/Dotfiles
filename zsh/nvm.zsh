# https://github.com/nvm-sh/nvm
# Basic NVM setup

# https://github.com/nvm-sh/nvm/issues/2724#issuecomment-1336537635
laxy-load-nvmrc() {
  # Lazy load
  # https://github.com/nvm-sh/nvm/issues/2724
  unset -f node nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

node() {
  lazy_load_nvm
  node $@
}

nvm() {
  lazy_load_nvm
  node $@
}
