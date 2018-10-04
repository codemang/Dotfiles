module MacDefaults
  extend self

  def self.execute
    # Hide the dock unless the cursor is over it (couldn't get to work with
    # defaults write'
    `osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'`

    # Remove delay when hovering over the dock
    `defaults write com.apple.Dock autohide-delay -float 0`

    # Hide all icons on dock
    `defaults write com.apple.finder CreateDesktop -bool false && killall Finder`

    # Make a new directory for screenshots
    `mkdir -p ~/Screenshots`
    `defaults write com.apple.screencapture location ~/Screenshots`

    # Set finder display type to Cover Flow
    `defaults write com.apple.Finder FXPreferredViewStyle Flwv`

    # Show battery as a percentage
    `defaults write com.apple.menuextra.battery ShowPercent YES`

    # Set key repeats delay to smallest amount: REQUIRES REBOOT
    `defaults write NSGlobalDomain KeyRepeat -int 2`
    `defaults write NSGlobalDomain InitialKeyRepeat -int 15`

    # Set Spectacle to start on login: REQUIRES REBOOT
    `osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Spectacle.app", hidden:false}'`

    # Set items in top bar
    `defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Clock.menu” "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/Displays.menu”`

    # Hide all icons on Desktop
    `defaults write com.apple.finder CreateDesktop false`
  end
end
