# macOS-only tools: tmux clipboard fix, nerd font for nvim icons, zsh, file sync (macOS)
require_macos
brew_install \
  reattach-to-user-namespace \
  font-hack-nerd-font \
  zsh \
  zsh-syntax-highlighting \
  unison \
  eugenmayer/dockersync/unox
