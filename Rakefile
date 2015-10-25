namespace :dotfiles do
  @dotfile_dir = File.dirname(__FILE__)
  @symlink_files_dir = File.join @dotfile_dir, "symlink_files"

  def print_header(message)
    puts "\e[0;32m--------------------------------------------\e[0m"
    puts "\e[0;32m            #{message}                      \e[0m"
    puts "\e[0;32m--------------------------------------------\e[0m"
  end

  def create_if_no_dir(dir)
    if !File.directory? File.join @dotfile_dir, dir
      system "mkdir #{File.join @dotfile_dir, dir}"
    end
  end

  task :install_vim_plugins do
    print_header "INSTALLING VIM PLUGINS"
    create_if_no_dir File.join "symlink_files/.vim"
    create_if_no_dir File.join "symlink_files/.vim/bundle"
    create_if_no_dir File.join "symlink_files/.vim/autoload"
    create_if_no_dir File.join "symlink_files/.vim/colors"

    color_dir = File.join @symlink_files_dir, ".vim/colors"
    system "curl https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim > #{color_dir}/solarized.vim"
    system "curl https://github.com/flazz/vim-colorschemes/blob/master/colors/codeschool.vim > #{color_dir}/codeschool.vim"

    plug_dir = File.join @symlink_files_dir, ".vim/autoload/plug.vim"
    if !File.file? plug_dir
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    else
      system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"
    end

    puts "\n\n"
  end

  task :symlink do
    print_header("SYMLINKING DOTFILES")
    symlink_files = %w{.vim .oh-my-zsh .zshrc .vimrc .gitconfig}
    for file in symlink_files
      system "ln -s #{@symlink_files_dir}/#{file} ~/.#{file}"
    end
  end

  task :update_self do
    print_header("UPDATING DOTFILES REPO")
    # TODO
    # if dirty changes
    #   abort
    # end
    Dir.chdir @dotfile_dir
    system "git fetch --all; git reset --hard origin/master"
    puts "\n\n"
  end

  task :source_files do
    print_header("SOURCING DOTFILES")
    system "source #{@dotfile_dir}/.zshrc"
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

    if !File.directory? File.join @symlink_files_dir, ".oh-my-zsh"
      system "git clone git://github.com/robbyrussell/oh-my-zsh.git #{@symlink_files_dir}/.oh-my-zsh"
    end

    cur_shell = `echo $SHELL`
    if !(cur_shell =~ /zsh/)
      `chsh -s $(which zsh)`
    end

    puts "\n\n"
  end

  task :check_for_existing_dotfiles do

  end

  task :install_home_brew do
    print_header("UPDATING BREW")
    good = system "brew --version"
    if !good
      system "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    else
      system "brew update -v"
    end

    good = `brew --version`
    if !good =~ /\d\.\d\.\d/
      fail "\e[0;31mThere was an error when trying to install/update homebrew. Possible causes are a broken ruby installation.\e[0m"
    end

    puts "\n\n"
  end

  task :install => [:update_self, :install_home_brew, :install_zsh, :symlink, :install_vim_plugins, :source_files] do
    puts "****************************************************"
    puts "                    All done :)"
    puts "****************************************************"
  end
end

task :default => ["dotfiles:install"]
