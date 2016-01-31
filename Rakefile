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
    # Create the directory structure for vim plugins
    create_if_no_dir 'symlink_files/vim'
    create_if_no_dir 'symlink_files/vim/bundle'
    create_if_no_dir 'symlink_files/vim/autoload'
    create_if_no_dir 'symlink_files/vim/colors'

    # Make sure vim plug is installed
    plug_dir = File.join @symlink_files_dir, 'vim/autoload/plug.vim'
    if !File.file? plug_dir
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end

    # Download vim color schemes
    color_dir = File.join @symlink_files_dir, 'vim/colors'
    File.read(File.join(@dotfile_dir, 'vim-colorschemes')).split("\n").each do |colorscheme_url|
      colorscheme_name = /^.*\/(\w+?\.vim)$/.match(colorscheme_url)[1]
      system "curl #{colorscheme_url} > #{File.join(color_dir, colorscheme_name)}"
    end

    # Install vim plugins and upgrade vim plug
    system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"
  end


  task :symlink do
    symlink_files = %w{tmux.conf vim oh-my-zsh zshrc vimrc gitconfig}
    symlink_files.map{|file| system "ln -s #{@symlink_files_dir}/#{file} ~/.#{file}"}
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
