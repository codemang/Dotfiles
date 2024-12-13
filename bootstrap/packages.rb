class Packages
  def self.kegs
    [
      'chruby',
      'cmake',
      'curl',
      'diff-so-fancy',
      'font-hack-nerd-font', # Used for icons in nvim.
      'fnm', # Node version manager.
      'fzf',
      'git',
      'git-lfs',
      'unison',
      'eugenmayer/dockersync/unox',
      { "package_name": 'heroku', "package_source": 'heroku/brew' },
      'htop',
      'neovim',
      'lua-language-server', # Needed for sumneko LSP in vim
      'nmap',
      'readline',
      'reattach-to-user-namespace',
      'ripgrep',
      'ruby',
      'ruby-build',
      'ruby-install',
      'solargraph', # Needed for Ruby support for Vim's CoC plugin.
      'tldr',
      'tmux',
      'yarn',
      'zsh',
      'zsh-syntax-highlighting'
    ]
  end

  def self.casks
    %w[
      1password
      alfred
      anki
      authy
      blender
      chromedriver
      docker
      dropbox
      firefox
      google-chrome
      google-drive
      grammarly
      harvest
      iterm2
      kindle
      sketch
      skitch
      slack
      spectacle
      spotify
      sublime-text
      xquartz
    ]
  end

  def self.gems
    [
      'rake',
      # Better man pages - https://tldr.sh/
      'tldr',
      'tmuxinator',
    ]
  end

  def self.npm_packages
    [
      'instant-markdown-d',
      'eslint_d', # Used to format JSX code in NeoVim.
      'neovim',
      'npm',
      'vtop'
    ]
  end
end
