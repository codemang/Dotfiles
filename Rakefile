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

  def good_exit_from_command?(command)
    system command
  end

  task :install_vim_plugins do
    print_header "INSTALLING VIM PLUGINS"
    create_if_no_dir File.join "symlink_files/vim"
    create_if_no_dir File.join "symlink_files/vim/bundle"
    create_if_no_dir File.join "symlink_files/vim/autoload"
    create_if_no_dir File.join "symlink_files/vim/colors"

    color_dir = File.join @symlink_files_dir, "vim/colors"
    system "curl https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim > #{color_dir}/solarized.vim"
    system "curl https://github.com/flazz/vim-colorschemes/blob/master/colors/codeschool.vim > #{color_dir}/codeschool.vim"

    plug_dir = File.join @symlink_files_dir, "vim/autoload/plug.vim"
    if !File.file? plug_dir
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end

    system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"

    puts "\n\n"
  end

  task :symlink do
    print_header("SYMLINKING DOTFILES")
    symlink_files = %w{tmux.conf vim oh-my-zsh zshrc vimrc gitconfig}
    for file in symlink_files
      system "ln -s #{@symlink_files_dir}/#{file} ~/.#{file}"
    end
  end

  task :source_files do
    print_header("SOURCING DOTFILES")
    system "source #{@dotfile_dir}/.zshrc"
    puts "\n\n"
  end

  task :install_zsh do
    if good_exit_from_command?('zsh --version')
      system "brew upgrade zsh"
      system "upgrade_oh_my_zsh"
    else
      system "brew install zsh"
      system "git clone git://github.com/robbyrussell/oh-my-zsh.git #{@symlink_files_dir}/.oh-my-zsh"
    end

    `chsh -s $(which zsh)` if `echo $SHELL` !~ /^.*zsh/
  end


  task :install_home_brew do
    if good_exit_from_command?('brew --version')
      system "brew update"
    else
      system "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    end
    system "brew doctor"
  end

  task :install => [:install_home_brew, :install_zsh, :symlink, :install_vim_plugins, :source_files] do
    puts "****************************************************"
    puts "                    All done :)"
    puts "****************************************************"
  end
end

namespace :clean do
  task :remove_files do
    system "rm ~/.zshrc"
    system "rm ~/.vimrc"
    system "rm ~/.oh-my-zsh"
    system "rm ~/.tmux.conf"
    system "rm ~/.gitconfig"
  end
end

task :default => ["dotfiles:install"]
