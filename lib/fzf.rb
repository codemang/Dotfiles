class Fzf
  def self.install
    Homebrew.install_keg('fzf') unless Homebrew.keg_installed?('fzf')
    `$(brew --prefix)/opt/fzf/install`
  end
end
