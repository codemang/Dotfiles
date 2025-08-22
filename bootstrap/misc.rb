class Misc
  def self.install
    # Install terminfos that are used to enable true colors + italics system-wide.
    # https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be#:~:text=Configure%20iTerm,to%20xterm%2D256color%2Ditalic%20.
    `tic -x #{File.join(Dir.pwd, 'iterm/xterm-256color-italic.terminfo')}`
    `tic -x #{File.join(Dir.pwd, 'iterm/tmux-256color.terminfo')}`

    # Set Desktop background images to personal images
    system('sudo rm /Library/Desktop\\ Pictures/* > /dev/null 2>&1')
    system('sudo cp ~/Dotfiles/assets/desktop-images/* /Library/Desktop\\ Pictures')

    # Configure Desktop background
    script = <<-EOS
      tell application "System Events"
        tell every desktop
          set picture rotation to 1 -- (0=off, 1=interval, 2=login, 3=sleep)
          set random order to true
          set change interval to 60.0 -- seconds
        end tell
      end tell
    EOS

    system 'osascript', *script.split(/\n/).map { |line| ['-e', line] }.flatten

    # Other
    `mkdir -p ~/Personal`

    # Set the global git ignore file
    system("git config --global core.excludesFile ~/.gitignore_global")
  end
end
