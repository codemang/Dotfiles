# Global Ruby gems
gems=(
  rake
  tldr # Better man pages: https://tldr.sh/
  tmuxinator
)
install_missing "gem list --no-versions" 'gem install' "${gems[@]}"
