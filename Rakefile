Dir['./bootstrap/**/*.rb'].each {|file| require file }

task :xcode do
  Xcode.install
end

task :kegs do
  puts 'Starting brew keg installation'
  Homebrew.install_homebrew

  existing_kegs = Homebrew.list_kegs
  PackageList.kegs.each do |keg|
    puts "* #{keg}"
    Homebrew.install_keg(keg) unless existing_kegs.include?(keg)
  end

  puts "\nCompleted brew keg installation"
end

task :casks do
  puts 'Starting brew cask installation'
  Homebrew.install_homebrew_cask

  existing_casks = Homebrew.list_casks
  PackageList.casks.each do |cask|
    puts "* #{cask}"
    Homebrew.install_cask(cask) unless existing_casks.include?(cask)
  end

  puts "\nCompleted brew cask installation"
end

task :gems do
  RubyGems.install_gems(PackageList.gems, {ignore_existing: true})
end

task :packages => [:kegs, :casks, :gems]

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
  :packages,
  :languages,
  :zsh,
  :dotfiles,
  :vim,
  :mac_defaults,
  :complete_msg
]
