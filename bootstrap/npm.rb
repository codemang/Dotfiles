# Depends on node being installed

module NPM
  extend self

  def list_packages
    root = `npm root -g`
    `ls #{root}`.split("\n")
  end

  def install_package(package)
    `npm install -g #{pacakge}`
  end

  def self.install_packages(packages, opts={})
    existing_packages = opts[:ignore_existing] ? list_packages : []
    packages.each do |package|
      if !existing_packages.include?(package)
        install_package(package)
        puts "* #{package} - newly installed" if opts[:log_output]
      else
        puts "* #{package} - already installed" if opts[:log_output]
      end
    end
  end
end
