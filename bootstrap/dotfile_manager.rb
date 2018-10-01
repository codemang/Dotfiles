class DotfileManager
  def self.symlink_dotfiles_and_print
    file_changes = symlink_files
    print_file_changes(file_changes)
  end

  def self.symlink_files
    file_changes = {
      properly_symlinked_files: [],
      newly_symlinked_files: [],
      replaced_symlinked_files: [],
    }

    files_to_symlink.each do |symlink_source|
      pending_dotfile =  Dir.home + "/." + File.basename(symlink_source, '.sym')

      if File.exists?(pending_dotfile)
        current_symlink_source = `readlink -n #{pending_dotfile}`
        if current_symlink_source == symlink_source
          file_changes[:properly_symlinked_files] << pending_dotfile
        else
          file_changes[:replaced_symlinked_files] << pending_dotfile
          `mv #{pending_dotfile} #{pending_dotfile}.replaced`
          system "ln -s #{File.expand_path(symlink_source)} #{pending_dotfile}"
        end
      else
        file_changes[:newly_symlinked_files] << pending_dotfile
        system "ln -s #{File.expand_path(symlink_source)} #{pending_dotfile}"
      end
    end

    file_changes
  end

  def self.files_to_symlink
    @files_to_symlink ||= begin
      dot_dir = File.expand_path('..', File.dirname(__FILE__))
      file_pattern = File.join(dot_dir, '**', '*')
      Dir.glob(file_pattern).select{|file| file =~ /^.*\.sym$/}
    end
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
