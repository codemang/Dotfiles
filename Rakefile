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

task :dotfiles do
  DotfileManager.symlink_dotfiles_and_print
end

task :all => [
  :packages,
  :languages,
  :zsh,
  :dotfiles,
  :vim,
]
