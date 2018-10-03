# Hide the dock unless the cursor is over it (couldn't get to work with
# defaults write'
osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'

# Remove delay when hovering over the dock
defaults write com.apple.Dock autohide-delay -float 0

# Hide all icons on dock
defaults write com.apple.finder CreateDesktop -bool false && killall Finder

# Make a new directory for screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# Set finder display type to Cover Flow
defaults write com.apple.Finder FXPreferredViewStyle Flwv

# Show battery as a percentage
defaults write com.apple.menuextra.battery ShowPercent YES

# Set key repeats delay to smallest amount: REQUIRES REBOOT
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Restart anything that used the changed settings
killall Dock
killall Finder
killall SystemUIServer
