require_relative './base_package_manager'

class Brew
  include BasePackageManager

  def self.list_packages
    `brew leaves`.split("\n").map(&:strip)
  end

  def self.install_package_manager
    system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
  end

  def self.install_packages(packages = [], opts = {})
    super(packages, opts)
  end

  private

  def self.install_package(package)
    if package["package_source"]
      `brew tap #{package['package_source']} && brew install #{package['package_name']}`
    else
      `brew install #{package}`
    end
  end
end
