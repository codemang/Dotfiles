# Global Ruby gems, for mise's Ruby (needs mise)
gems=(
  rake
  tldr # Better man pages: https://tldr.sh/
  tmuxinator
  solargraph # Ruby support for Vim's CoC plugin.
)
gem_install "${gems[@]}"
