Dir['./lib/*.rb'].each {|file| require file }

task :packages do
  Xcode.install
  Homebrew.install_kegs(PackageList.kegs, {ignore_existing: true})
  Homebrew.install_casks(PackageList.casks, {ignore_existing: true})
  RubyGems.install_gems(PackageList.gems, {ignore_existing: true})
  Ruby.install
  Zsh.install
end

task :dotfiles do
  DotfileManager.symlink_dotfiles_and_print
end

task :setup => ["dotfiles:setup"]
