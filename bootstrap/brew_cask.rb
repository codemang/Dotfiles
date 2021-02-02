require_relative './base_package_manager'

class BrewCask
  include BasePackageManager

  def self.list_packages
    `brew list --cask`.split("\n")
  end

  private

  def self.install_package(package)
    `brew install --cask #{package}`
  end
end
