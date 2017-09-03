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

    files_to_symlink.each do |sym_filepath|
      dest_filepath =  Dir.home + "/." + File.basename(sym_filepath, '.sym')

      if File.exists?(dest_filepath)
        symlink_location = `readlink -n #{dest_filepath}`
        if symlink_location == File.expand_path(sym_filepath)
          file_changes[:properly_symlinked_files] << dest_filepath
        else
          file_changes[:replaced_symlinked_files] << dest_filepath
          `mv #{dest_filepath} #{dest_filepath}.replaced`
          system "ln -s #{File.expand_path(sym_filepath)} #{dest_filepath}"
        end
      else
        file_changes[:newly_symlinked_files] << dest_filepath
        system "ln -s #{File.expand_path(sym_filepath)} #{dest_filepath}"
      end
    end

    file_changes
  end

  def self.files_to_symlink
    @files_to_symlink ||= Dir.glob("../**/*").select{|file| file =~ /^.*\.sym$/}
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
      print_file_list(files
      puts
    end
  end

  def self.print_file_list(files)
    files.each do |file|
      puts " * #{file}"
    end
  end
end

DotfileManager.symlink_dotfiles_and_print
