require_relative './base_package_manager'

class NPM
  include BasePackageManager

  def self.list_packages
    root = `npm root -g`
    `ls #{root}`.split("\n")
  end

  private

  def self.install_package(package)
    `npm install -g #{package}`
  end
end
