# Assumes neovim is installed
class Vim
  # Support macvim and neovim

  def self.install
    install_plugin_manager
    install_vim_plugins
  end

  def self.install_plugin_manager
    plug_dir = File.join(Dir.home, '.local/share/nvim/site/autoload/plug.vim')
    if !File.file?(plug_dir)
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end
  end

  def self.install_vim_plugins
    system("nvim +PlugInstall +qall")
  end
end
