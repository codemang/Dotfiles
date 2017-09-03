Dir['./lib/*.rb'].each {|file| require file }

namespace :dotfiles do
  task :setup do
    Homebrew.install_kegs(PackageList.kegs)
    Zsh.install
  end
end

task :setup => ["dotfiles:setup"]
