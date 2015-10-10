namespace :dotfiles do
  @dotfile_dir = "Dotfiles"
  @dotfile_root = File.expand_path "~/"
  @symlink_files_root = File.join @dotfile_root, @dotfile_dir, "symlink_files"

  def dotfile_path
    File.join @dotfile_root, @dotfile_dir
  end


  def print_header(message)
    puts "--------------------------------------------"
    puts "            #{message}                      "
    puts "--------------------------------------------"
  end

  def create_if_no_dir(dir)
    if !File.directory? File.join @dotfile_root, dir
      system "mkdir #{File.join @dotfile_root, dir}"
    end
  end

  task :install_vim_plugins do
    print_header "INSTALLING VIM PLUGINS"
    create_if_no_dir ".vim"
    create_if_no_dir ".vim/bundle"
    create_if_no_dir ".vim/autoload"
    create_if_no_dir ".vim/colors"

    color_dir = File.join @dotfile_root, ".vim/colors"
    system "curl https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim > #{color_dir}/solarized.vim"

    if !File.file? File.join @dotfile_root, ".vim/autoload/plug.vim"
      system "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    else
      system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"
    end
   
    puts "\n\n"
  end

  task :symlink do
    print_header("SYMLINKING DOTFILES")
    Dir.foreach(@symlink_files_root) do |item|
      next if item == '.' or item == '..'
      system "ln -s #{@symlink_files_root}/#{item} ~/#{item}" 
    end
    puts "\n\n"
  end

  task :download_dotfiles do
    print_header("DOWNLOADING DOTFILES")
    if File.directory? dotfile_path
      Dir.chdir dotfile_path
      system "git fetch --all; git reset --hard origin/master"
    else
      system "git clone https://github.com/codemang/Dotfiles #{dotfile_path}"
    end
    puts "\n\n"
  end

  task :source_files do
    print_header("SOURCING DOTFILES")
    system "source #{@dotfile_root}/.zshrc"
    puts "\n\n"
  end

    
  task :install_zsh do
    print_header("UPDATING ZSH")
    good = system "zsh --version"

    if !good
      # system "brew install zsh"
    else
      system "brew upgrade zsh"
    end

    system "git clone git://github.com/robbyrussell/oh-my-zsh.git #{dotfile_path}/oh-my-zsh"

    cur_shell = `echo $SHELL`
    if !(cur_shell =~ /zsh/)
      `chsh -s $(which zsh)`
    end

    puts "\n\n"
  end

  task :install_home_brew do
    print_header("UPDATING BREW")
    good = system "brew --version"
    if !good
      system "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    else
      system "brew update -v"
    end
    puts "\n\n"
  end

  task :set_args do
    puts "#{ENV['path']}!"
    if ENV['path'] != nil
      @dotfile_dir = ENV['path']
    end
  end


  task :install => [:set_args, :install_home_brew, :install_zsh, :download_dotfiles, :symlink, :install_vim_plugins, :source_files] do
    puts "****************************************************"
    puts "                    All done :)"
    puts "****************************************************"
  end
end

task :default => ["dotfiles:install"]

task :test do
  ENV['path'] = "test-dotfiles"
  Rake.application.invoke_task("default")
end
