class Vim
  def self.install
    install_plugin_manager
    install_vim_plugins
  end

  def self.install_plugin_manager
    plug_dir = File.join(Dir.home, '.vim/autoload/plug.vim')
    if !File.file?(plug_dir)
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end
  end

  def self.install_vim_plugins
    system("mvim -v +PlugUpgrade +qall")
    system("mvim -v +PlugInstall +qall")
  end
end
