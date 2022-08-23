class Packages
  def self.python_packages
    [
      "pynvim", # Needed for the 'coq_nvim' NeoVim plugin.
    ]
  end

  def self.kegs
    [
      "chruby",
      "cmake",
      "curl",
      "diff-so-fancy",
      "fzf",
      "git",
      "git-lfs",
      "unison",
      "eugenmayer/dockersync/unox",
      { "package_name": "heroku", "package_source": "heroku/brew" },
      "htop",
      "neovim",
      "nmap",
      "readline",
      "reattach-to-user-namespace",
      "ripgrep",
      "ruby",
      "ruby-build",
      "ruby-install",
      "solargraph", # Needed for Ruby support for Vim's CoC plugin.
      "tldr",
      "tmux",
      "yarn",
      "zsh",
      "zsh-syntax-highlighting",
    ]
  end

  def self.casks
    [
      "1password",
      "alfred",
      "anki",
      "authy",
      "chromedriver",
      "docker",
      "dropbox",
      "firefox",
      "google-chrome",
      "google-drive",
      "grammarly",
      "harvest",
      "iterm2",
      "kindle",
      "sketch",
      "skitch",
      "slack",
      "spectacle",
      "spotify",
      "sublime-text",
      "xquartz"
    ]
  end

  def self.gems
    [
      "bigdecimal",
      "byebug",
      "cmath",
      "csv",
      "date ",
      "docker-sync",
      "fileutils",
      "foreman",
      "json",
      "msgpack",
      "msgpack-rpc",
      "octokit",
      "openssl",
      "rake",
      "solargraph"
    ]
  end

  def self.npm_packages
    [
      "instant-markdown-d",
      "neovim",
      "npm",
      "vtop"
    ]
  end
end
