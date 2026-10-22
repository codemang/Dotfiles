require 'fileutils'
require 'shellwords'

module MacDefaults
  def self.execute
    # Hide the dock unless the cursor is over it (couldn't get to work with
    # defaults write'
    `osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'`

    # Remove delay when hovering over the dock
    `defaults write com.apple.Dock autohide-delay -float 0`

    # Hide all icons on Desktop
    `defaults write com.apple.finder CreateDesktop -bool false`

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

    # Only show running apps in Dock
    `defaults write com.apple.dock static-only -bool true`

    setup_iterm
  end

  # Load iTerm's settings from iterm/ in this repo and save changes back to it.
  # Done here instead of in iTerm's Settings window, which saves iTerm's current
  # (stock) settings over the repo copy when turned on.
  def self.setup_iterm
    if system('pgrep -x iTerm2 > /dev/null')
      puts 'Skipping iTerm settings: quit iTerm and rerun `rake mac_defaults` from Terminal.app'
      return
    end

    # Create the default 'Nate Color Overrides' profile before iTerm launches,
    # otherwise iTerm falls back to 'Nate Defaults' as the default profile.
    # `tc` (util/toggle_colors.sh) replaces it when switching color schemes.
    dynamic_profiles = File.expand_path('~/Library/Application Support/iTerm2/DynamicProfiles')
    color_profile = File.join(dynamic_profiles, 'color-scheme.json')
    unless File.exist?(color_profile)
      FileUtils.mkdir_p(dynamic_profiles)
      FileUtils.cp(File.join(Dir.pwd, 'iterm/color_schemes/bearded-arc.json'), color_profile)
    end

    `defaults write com.googlecode.iterm2 PrefsCustomFolder -string #{File.join(Dir.pwd, 'iterm').shellescape}`
    `defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true`
    # 2 = "Save changes: Automatically"
    `defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2`
  end
end
