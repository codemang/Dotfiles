namespace :dotfiles do
  @dotfile_dir = File.dirname(__FILE__)
  @symlink_files_dir = File.join @dotfile_dir, 'symlink_files'

  def create_if_no_dir(dir)
    if !File.directory? File.join @dotfile_dir, dir
      system "mkdir #{File.join @dotfile_dir, dir}"
    end
  end

  def good_exit_from_command?(command)
    system command
  end


  task :install_home_brew do
    if good_exit_from_command?('brew --version')
      system 'brew update'
    else
      system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    end
    system 'brew doctor'
  end


  task :install_zsh do
    if good_exit_from_command?('zsh --version')
      system 'brew upgrade zsh'
      system 'upgrade_oh_my_zsh'
    else
      system 'brew install zsh'
      system "git clone git://github.com/robbyrussell/oh-my-zsh.git #{@symlink_files_dir}/.oh-my-zsh"
    end

    `chsh -s $(which zsh)` if `echo $SHELL` !~ /^.*zsh/
  end


  task :install_vim_plugins do
    # Make sure vim plug is installed
    plug_dir = File.join @symlink_files_dir, 'vim/autoload/plug.vim'
    if !File.file? plug_dir
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end

    # Install vim plugins and upgrade vim plug
    system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"
  end


  task :symlink do
    Dir.glob("**/*").select{|file| file =~ /^.*\.sym$/}.each do |sym_filepath|
      new_filename =  File.basename(sym_filepath, '.sym')
      system "ln -s #{File.join(@dotfile_dir, sym_filepath)} ~/.#{new_filename}"
    end
  end


  task :install => [:install_home_brew, :install_zsh, :symlink, :install_vim_plugins] do
    puts "****************************************************"
    puts "                    All done :)"
    puts "****************************************************"
  end

  task :remove_files do
    system "rm ~/.zshrc"
    system "rm ~/.vimrc"
    system "rm ~/.oh-my-zsh"
    system "rm ~/.tmux.conf"
    system "rm ~/.gitconfig"
  end
end

task :default => ["dotfiles:install"]
task :clean => ["dotfiles:remove_files"]
