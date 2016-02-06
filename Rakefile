require_relative 'functional_helpers'
include FunctionalHelpers

namespace :dotfiles do
  task :install_home_brew do
    print_header 'Installing/Upgrading homebrew and all brews/casks'

    if good_exit_from_command?('brew --version')
      system 'brew update'
    else
      system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    end
    system 'brew doctor'
    print_footer
  end


  task :install_zsh do
    print_header 'Installing/Upgrading zsh'

    if good_exit_from_command?('zsh --version')
      system 'brew upgrade zsh'
    else
      system 'brew install zsh'
    end

    if File.exist? File.expand_path("~/.oh-my-zsh")
      system 'upgrade_oh_my_zsh'
    else
      system "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
    end

    `chsh -s $(which zsh)` if `echo $SHELL` !~ /^.*zsh/
    print_footer
  end


  task :install_vim_plugins do
    print_header 'Installing/Upgrading all vim plugins'

    # Make sure vim plug is installed
    plug_dir = File.join Dir.home, '.vim/autoload/plug.vim'
    if !File.file? plug_dir
      system "curl -fLo #{plug_dir} --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    end

    # Install vim plugins and upgrade vim plug
    system "$EDITOR -c ':PlugInstall' -c 'qa!'"
    system "$EDITOR -c 'PlugUpgrade' -c 'qa!'"
  end


  task :symlink do
    print_header 'Symlinking files to home directory'

    Dir.glob("**/*").select{|file| file =~ /^.*\.sym$/}.each do |sym_filepath|
      new_filepath =  Dir.home + "/." + File.basename(sym_filepath, '.sym')
      system "ln -v -s #{File.expand_path(sym_filepath)} #{new_filepath}" if !File.exists?(new_filepath)
    end
    print_footer
  end

  task :setup => [:install_home_brew, :install_zsh, :symlink] do
    print_header "Source your .zshrc and run 'rake update'"
  end

  task :update => [:install_vim_plugins] do
  end

  task :remove_files do
    system "rm ~/.zshrc"
    system "rm ~/.vimrc"
    system "rm ~/.vim"
    system "rm ~/.tmux.conf"
    system "rm ~/.gitconfig"
    system "rm -rf ~/.oh-my-zsh"
  end
end

task :default => ["dotfiles:update"]
task :update => ["dotfiles:update"]
task :setup => ["dotfiles:setup"]
task :clean => ["dotfiles:remove_files"]
