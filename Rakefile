Dir['./lib/*.rb'].each {|file| require file }

task :packages do
  Homebrew.install_kegs(PackageList.kegs)
  Homebrew.install_casks(PackageList.casks)
  Ruby.install
  RubyGems.install_gems(PackageList.gems)
  Zsh.install
end

task :dotfiles do

end




task :setup => ["dotfiles:setup"]
