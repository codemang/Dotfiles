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
      system 'upgrade_oh_my_zsh'
    else
      system 'brew install zsh'
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
    print_footer
  end


  task :symlink do
    print_header 'Symlinking files to home directory'

    Dir.glob("**/*").select{|file| file =~ /^.*\.sym$/}.each do |sym_filepath|
      new_filepath =  Dir.home + "/." + File.basename(sym_filepath, '.sym')
      system "ln -v -s #{File.expand_path(sym_filepath)} #{new_filepath}" if !File.exists?(new_filepath)
    end
    print_footer
  end


  task :install => [:install_home_brew, :install_zsh, :symlink, :install_vim_plugins] do
    print_header "Done! You da best!"
  end

  task :remove_files do
    system "rm ~/.zshrc"
    system "rm ~/.vimrc"
    system "rm ~/.vim"
    system "rm ~/.oh-my-zsh"
    system "rm ~/.tmux.conf"
    system "rm ~/.gitconfig"
  end
end

task :default => ["dotfiles:install"]
task :clean => ["dotfiles:remove_files"]
