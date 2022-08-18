# Assumes neovim is installed
class Vim
  # Support macvim and neovim

  def self.install
    install_vim_plugins
  end

  def self.install_vim_plugins
    system("nvim +PlugInstall +qall")
  end
end
