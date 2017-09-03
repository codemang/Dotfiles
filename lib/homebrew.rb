class Homebrew
  def self.keg_installed?(keg)
    `brew list | grep #{keg}`.empty?
  end

  def self.install_homebrew
    system("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
  end

  def self.install_homebrew_cask
    system("brew tap phinze/homebrew-cask")
    system("brew install brew-cask")
  end

  def self.install_keg(keg)
    `brew install #{keg}`
  end

  def self.install_kegs(kegs, opts={})
    existing_kegs = opts[:ignore_existing] ? list_kegs : []
    kegs.each do |keg|
      if !existing_kegs.include?(keg)
        install_keg(keg)
      end
    end
  end

  def self.install_cask(cask)
    system("brew cask install #{cask}")
  end

  def self.install_casks(casks, opts={})
    existing_casks = opts[:ignore_existing] ? list_casks : []
    casks.each do |cask|
      if !existing_casks.include?(cask)
        install_cask(cask)
      end
    end
  end

  def self.list_kegs
    `brew list`.split("\n")
  end

  def self.list_casks
    `brew cask list`.split("\n")
  end
end
