# macOS system settings, and iTerm loading its settings from this repo (macOS)
require_macos
# Hide the dock unless the cursor is over it, with no delay.
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
defaults write com.apple.Dock autohide-delay -float 0
# Only show running apps in the dock.
defaults write com.apple.dock static-only -bool true
# Hide all icons on the desktop.
defaults write com.apple.finder CreateDesktop -bool false
# Screenshots go to ~/Screenshots.
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
# Finder: Cover Flow view.
defaults write com.apple.Finder FXPreferredViewStyle Flwv
# Battery as a percentage.
defaults write com.apple.menuextra.battery ShowPercent YES
# Shortest key repeat delays (takes effect after a reboot).
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Start Spectacle on login (takes effect after a reboot).
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Spectacle.app", hidden:false}'
# Menu bar items.
defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/Clock.menu" \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/Displays.menu"

# iTerm loads its settings from iterm/ in this repo and saves changes back to it.
# Done here, not in iTerm's Settings window, which would save iTerm's current
# (stock) settings over the repo copy when turned on.
if pgrep -x iTerm2 > /dev/null; then
  warn "skipping iTerm settings: quit iTerm and rerun 'install.sh mac-defaults' from Terminal.app"
  exit 0
fi
# Create the default 'Nate Color Overrides' profile before iTerm launches, or iTerm
# falls back to 'Nate Defaults'. `tc` (util/toggle_colors.sh) replaces it.
profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
if [[ ! -f "$profiles/color-scheme.json" ]]; then
  mkdir -p "$profiles"
  cp "$DOTFILES_DIR/iterm/color_schemes/bearded-arc.json" "$profiles/color-scheme.json"
fi
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2 # Save changes automatically.
