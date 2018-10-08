class Misc
  def self.install
    `mkdir -p ~/Personal`

    # Set Desktop background images to personal images
    system("sudo rm /Library/Desktop\\ Pictures/* > /dev/null 2>&1")
    system("sudo cp ~/Dotfiles/desktop-images/* /Library/Desktop\\ Pictures")

    # Configure Desktop background
    script = <<-eos
      tell application "System Events"
        tell every desktop
          set picture rotation to 1 -- (0=off, 1=interval, 2=login, 3=sleep)
          set random order to true
          set change interval to 60.0 -- seconds
        end tell
      end tell
    eos
    system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten
  end
end
