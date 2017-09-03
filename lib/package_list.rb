require 'json'
require './homebrew'

class PackageList
  def self.kegs
    package_list['kegs']
  end

  def self.package_list
    @package_list ||= begin
      dot_dir = File.expand_path('..', File.dirname(__FILE__))
      contents = File.read(File.join(dot_dir, 'packages.json'))
      JSON.parse(contents)
    end
    @package_list
  end

  def self.build_package_list
    {
      kegs: Homebrew.list_kegs,
    }
  end
end
