Dir['./bootstrap/**/*.rb'].each {|file| require file }

task :brew do
  puts_section_header('brew')
  puts 'Starting Homebrew installation'
  Brew.install_package_manager
  puts 'Installing individual kegs'
  Brew.install_packages(PackageList.kegs, log_output: true)
end


task :cask do
  puts_section_header('brew cask')
  puts 'Installing individual casks'
  BrewCask.install_packages(PackageList.casks, log_output: true)
end

task :npm_packages do
  puts_section_header('npm packages')
  puts 'Installing individual NPM packages'
  NPM.install_packages(PackageList.npm_packages, log_output: true)
end

task :gems do
  puts_section_header('gems')
  puts 'Installing individual gems'
  RubyGems.install_packages(PackageList.gems, log_output: true)
end

task :system_packages => [:brew, :cask]
task :language_packages => [:gems, :npm_packages]

task :export_packages do
  PackageList.save_package_list
end

task :languages do
  puts_section_header('languages')
  Ruby.install
end

task :zsh do
  puts_section_header('zsh')
  Zsh.install
end

task :vim do
  puts_section_header('vim')
  Vim.install
  Powerfonts.install
end

task :mac_defaults do
  puts_section_header('mac defaults')
  MacDefaults.execute
end

task :dotfiles do
  puts_section_header('dotfiles')
  DotfileManager.symlink_dotfiles_and_print
end

task :misc do
  Misc.install
end

def green_output(msg)
  puts "\e[#{32}m#{msg}\e[0m"
end

def puts_section_header(header)
  puts
  header_container = '=============================================================='
  first_half_space_length  = header_container.length/2 - (header.length/2 + 2)
  second_half_space_length = header_container.length - (4 + first_half_space_length + header.length)
  green_output(header_container)
  green_output("= "+' '*first_half_space_length + header.upcase + " "*second_half_space_length+" =")
  green_output(header_container)
  puts
end

task :complete_msg do
  puts
  green_output("====================== BOOTSTRAPPING COMPLETE ====================")
  green_output("Final Steps:")
  green_output("1) Restart your computer so that some configurations can take effect")
  green_output("2) Follow the manual steps in the README")
end

task :setup => [
  :system_packages,
  :languages,
  :language_packages,
  :zsh,
  :dotfiles,
  :vim,
  :misc,
  :mac_defaults,
  :complete_msg
]
