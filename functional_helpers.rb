module FunctionalHelpers

  def dotfile_dir
    @dotfile_dir ||= File.dirname(__FILE__)
  end

  def stepnum
    @stepnum ||= 1
    @stepnum
  end

  def good_exit_from_command?(command)
    system command
  end

  def print_header(message)
    puts "\e[0;32mStep #{stepnum}: #{message}\e[0m"
    # [0;32m--------------------------------------------\e[0m]]
    @stepnum += 1
  end

  def print_footer
    puts "\n\n"
  end

end
