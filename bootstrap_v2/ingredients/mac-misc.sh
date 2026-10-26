# Terminfo for true color + italics, desktop pictures, global gitignore (macOS)
require_macos
# https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
tic -x "$DOTFILES_DIR/iterm/xterm-256color-italic.terminfo"
tic -x "$DOTFILES_DIR/iterm/tmux-256color.terminfo"

sudo rm -f /Library/Desktop\ Pictures/* 2> /dev/null || true
sudo cp "$DOTFILES_DIR"/assets/desktop-images/* /Library/Desktop\ Pictures/
osascript \
  -e 'tell application "System Events"' \
  -e '  tell every desktop' \
  -e '    set picture rotation to 1 -- (0=off, 1=interval, 2=login, 3=sleep)' \
  -e '    set random order to true' \
  -e '    set change interval to 60.0 -- seconds' \
  -e '  end tell' \
  -e 'end tell'

mkdir -p ~/Personal
git config --global core.excludesFile ~/.gitignore_global
