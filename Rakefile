Dir['./lib/*.rb'].each {|file| require file }

task :packages do
  Xcode.install
  Homebrew.install_kegs(PackageList.kegs)
  Homebrew.install_casks(PackageList.casks)
  Ruby.install
  RubyGems.install_gems(PackageList.gems)
  Zsh.install
end

task :dotfiles do
  DotfileManager.symlink_dotfiles_and_print
end

task :setup => ["dotfiles:setup"]
