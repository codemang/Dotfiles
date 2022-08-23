require_relative './base_package_manager'
require 'byebug'

class PythonPackages
  include BasePackageManager

  def self.list_packages
    packages_output = `python3 -m pip list`
    packages_list = packages_output.split("\n")[2..] # Strip the first two lines of the output which dont' contain packages.

    package_names = packages_list.map do |package_line|
      package_line.split(" ")[0]
    end

    package_names
  end

  private

  def self.install_package(package)
    `python3 -m pip install --user --upgrade #{package}`
  end
end
