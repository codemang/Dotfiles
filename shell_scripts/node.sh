export PATH=/home/$USER/.fnm:$PATH
if command -v fnm > /dev/null; then
  eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fi

alias tsx="npx tsx"
