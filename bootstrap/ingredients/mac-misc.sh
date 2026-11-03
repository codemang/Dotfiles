# Terminfo for true color + italics, global gitignore (macOS)
require_macos
# https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
tic -x "$DOTFILES_DIR/iterm/xterm-256color-italic.terminfo"
tic -x "$DOTFILES_DIR/iterm/tmux-256color.terminfo"

mkdir -p ~/Personal
git config --global core.excludesFile ~/.gitignore_global
