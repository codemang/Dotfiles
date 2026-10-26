# Homebrew casks: GUI apps (macOS)
require_macos
casks=(
  1password alfred authy docker dropbox firefox
  google-chrome google-drive iterm2 kindle sketch skitch
  spectacle spotify sublime-text xquartz
)
install_missing 'brew list --cask -1' 'brew install --cask' "${casks[@]}"
