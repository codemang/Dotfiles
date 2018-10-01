# Make the dock hidden unless the cursor is over it
 defaults write com.apple.Dock autohide -bool true

 # Remove delay when hovering over the dock
 defaults write com.apple.Dock autohide-delay -float 0

 # Hide all icons on dock
 defaults write com.apple.finder CreateDesktop -bool false && killall Finder

 # Make a new directory for screenshots
 mkdir -p ~/Screenshots
 defaults write com.apple.screencapture location ~/Screenshots

 # Set finder display type to Cover Flow
 defaults write com.apple.Finder FXPreferredViewStyle Flwv

killall Dock
killall Finder
