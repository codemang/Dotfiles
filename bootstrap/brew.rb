require_relative './base_package_manager'

class Brew
  include BasePackageManager

  def self.list_packages
    `brew leaves`.split("\n").map(&:strip)
  end

  def self.install_package_manager
    system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
  end

  private

  def self.install_package(package)
    `brew install #{package}`
  end
end
