Dir['./bootstrap/**/*.rb'].each { |file| require file }

task :brew do
  puts_section_header('brew')
  puts 'Starting Homebrew installation'
  Brew.install_package_manager
  puts 'Installing individual kegs'
  Brew.install_packages(Packages.kegs, log_output: true)
end

task :cask do
  puts_section_header('brew cask')
  puts 'Installing individual casks'
  BrewCask.install_packages(Packages.casks, log_output: true)
end

task :npm_packages do
  puts_section_header('NPM Packages')
  NPM.install_packages(Packages.npm_packages, log_output: true)
end

task :gems do
  puts_section_header('Ruby Gems')
  RubyGems.install_packages(Packages.gems, log_output: true)
end

task system_packages: %i[brew cask]
task language_packages: %i[gems npm_packages]

task :languages do
  puts_section_header('languages')
  Ruby.install
  Fnm.install
end

task :zsh do
  puts_section_header('zsh')
  Zsh.install
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
  puts "\e[32m#{msg}\e[0m"
end

def puts_section_header(header)
  puts
  header_container = '=============================================================='
  first_half_space_length  = header_container.length / 2 - (header.length / 2 + 2)
  second_half_space_length = header_container.length - (4 + first_half_space_length + header.length)
  green_output(header_container)
  green_output('= ' + ' ' * first_half_space_length + header.upcase + ' ' * second_half_space_length + ' =')
  green_output(header_container)
  puts
end

task :complete_msg do
  puts
  green_output('====================== BOOTSTRAPPING COMPLETE ====================')
  green_output('Final Steps:')
  green_output('1) Restart your computer so that some configurations can take effect')
  green_output('2) Follow the manual steps in the README')
end

task setup: %i[
  system_packages
  languages
  language_packages
  zsh
  dotfiles
  misc
  mac_defaults
  complete_msg
]
