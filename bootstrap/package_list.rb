require 'json'
require_relative './brew'
require_relative './brew_cask'
require_relative './ruby_gems'
require_relative './npm'

class PackageList
  def self.method_missing(m, *args, &block)
    if package_list.keys.include?(m.to_s)
      package_list[m.to_s]
    else
      raise ArgumentError, "No function '#{m}' in #{self.name}"
    end
  end

  def self.package_list
    @package_list ||= JSON.parse(File.read(package_filepath))
  end

  def self.package_filepath
    @package_filepath ||= begin
      dot_dir = File.expand_path('..', File.dirname(__FILE__))
      File.join(dot_dir, 'packages.json')
    end
  end

  def self.build_package_list
    {
      kegs: Brew.list_packages,
      casks: BrewCask.list_packages,
      gems: RubyGems.list_packages,
      npm_packages: NPM.list_packages,
    }
  end

  def self.save_package_list
    file = File.open(package_filepath, 'w')
    file.truncate(0)
    file.write(JSON.pretty_generate(build_package_list))
  end
end
