require_relative './base_package_manager'

class RubyGems
  include BasePackageManager

  def self.list_packages
    `gem list | sed 's/(.*)//'`.split("\n")
  end

  def self.install_package(package)
    `gem install #{package}`
  end
end
