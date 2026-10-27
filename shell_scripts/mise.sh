# Node, Ruby and Python versions, via mise. Global versions are in dotfiles/mise.toml.
source "$DOTFILES/shell_scripts/ca_certs.sh"
if command -v mise > /dev/null; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(mise activate zsh)"
  else
    eval "$(mise activate bash)"
  fi
fi

alias tsx="npx tsx"
