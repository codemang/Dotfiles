class Packages
  def self.python_packages
    [
      'pynvim', # Needed for the 'coq_nvim' NeoVim plugin.
      'vim-vint', # Needed to lint/format the vimrc file.
      'beautysh', # Needed to format sh/zsh files.
      'neovim-remote', # Find running neovim processes in order to toggle their colorschemes.
    ]
  end

  def self.kegs
    [
      'chruby',
      'cmake',
      'curl',
      'diff-so-fancy',
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
      'bigdecimal',
      'byebug',
      'cmath',
      'csv',
      'date ',
      'docker-sync',
      'eslint_d', # Faster eslint client, used for linting JS/TS.
      'fileutils',
      'foreman',
      'json',
      'msgpack',
      'msgpack-rpc',
      'octokit',
      'openssl',
      'rake',
      'solargraph',
      # Better man pages - https://tldr.sh/
      'tldr',
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
