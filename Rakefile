Dir['./lib/*.rb'].each {|file| require file }

task :xcode do
  Xcode.install
end

task :kegs do
  Homebrew.install_kegs(PackageList.kegs, {ignore_existing: true})
end

task :casks do
  Homebrew.install_casks(PackageList.casks, {ignore_existing: true})
end

task :gems do
  RubyGems.install_gems(PackageList.gems, {ignore_existing: true})
end

task :packages => [:kegs, :casks, :gems] {}

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
] {}
