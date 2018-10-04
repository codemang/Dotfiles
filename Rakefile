Dir['./bootstrap/**/*.rb'].each {|file| require file }

task :xcode do
  Xcode.install
end

task :kegs do
  puts 'Starting brew keg installation'
  Homebrew.install_homebrew
  puts 'Installing individual kegs'
  Homebrew.install_kegs(PackageList.kegs, ignore_existing: true, log_output: true)
end

task :casks do
  puts 'Starting brew cask installation'
  Homebrew.install_homebrew_cask
  puts 'Installing individual casks'
  Homebrew.install_casks(PackageList.casks, ignore_existing: true, log_output: true)
end

task :npm_packages do
  puts 'Installing individual NPM packages'
  NPM.install_packages(PackageList.npm_packages, ignore_existing: true, log_output: true)
end

task :gems do
  puts 'Installing individual gems'
  RubyGems.install_gems(PackageList.gems, {ignore_existing: true, log_output: true})
end

task :system_packages => [:kegs, :casks]
task :language_packages => [:gems, :npm_packages]

task :export_packages do
  PackageList.save_package_list
end

task :languages do
  Ruby.install
end

task :zsh do
  Zsh.install
end

task :vim do
  Vim.install
end

task :mac_defaults do
  MacDefaults.execute
end

task :dotfiles do
  DotfileManager.symlink_dotfiles_and_print
end

def green_output(msg)
  puts "\e[#{32}m#{msg}\e[0m"
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
  :mac_defaults,
  :complete_msg
]
