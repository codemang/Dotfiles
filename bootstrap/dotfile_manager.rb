class DotfileManager
  # Support macvim and neovim
  SYMLINK_TARGETS = {
    'vim/vimrc.sym' => ['~/.config/nvim/init.vim', '~/.vimrc'],
    'vim/colors' => ['~/.local/share/nvim/site/colors', '~/.vim/colors'],
    'zsh/zshrc.sym' => ['~/.zshrc'],
    'tmux/tmux.conf.sym' => ['~/.tmux.conf'],
    'git/gitconfig.sym' => ['~/.gitconfig'],
  }

  def self.symlink_dotfiles_and_print
    file_changes = symlink_files
    print_file_changes(file_changes)
  end

  def self.symlink_files
    # required for neovim and macvim
    `mkdir -p ~/.local/share/nvim/site`
    `mkdir -p ~/.config/nvim`
    `mkdir -p ~/.vim`

    file_changes = {
      properly_symlinked_files: [],
      newly_symlinked_files: [],
      replaced_symlinked_files: [],
    }

    SYMLINK_TARGETS.each do |source, targets|
      targets.each do |target|
        full_source = File.join(Dir.pwd, source)
        full_target = File.expand_path(target)

        symlink_exists = `readlink -n #{full_target}`.length > 0
        if File.exists?(full_target) || symlink_exists
          current_symlink_source = `readlink -n #{full_target}`
          if current_symlink_source == full_source
            file_changes[:properly_symlinked_files] << full_target
          else
            file_changes[:replaced_symlinked_files] << full_target
            `mv #{full_target} #{full_target}.replaced`
            system "ln -s #{full_source} #{full_target}"
          end
        else
          file_changes[:newly_symlinked_files] << full_target
          system "ln -s #{full_source} #{full_target}"
        end
      end
    end

    file_changes
  end

  def self.print_file_changes(file_changes)
    print_if_changes_present(
      file_changes[:properly_symlinked_files],
      'These files were already properly symlinked to the Dotfiles repo'
    )
    print_if_changes_present(
      file_changes[:newly_symlinked_files],
      'These files were newly symlinked to the Dotfiles repo'
    )
    print_if_changes_present(
      file_changes[:replaced_symlinked_files],
      'These files already existed in the home directory and were replaced. Copies were made to "filename.replaced"'
    )
  end

  def self.print_if_changes_present(files, message)
    if files.count > 0
      puts message
      print_file_list(files)
      puts
    end
  end

  def self.print_file_list(files)
    files.each do |file|
      puts " * #{file}"
    end
  end
end
