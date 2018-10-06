require_relative './base_package_manager'

class BrewCask
  include BasePackageManager

  def self.list_packages
    `brew cask list`.split("\n")
  end

  private

  def self.install_package(package)
    `brew cask install #{package}`
  end
end
