module BasePackageManager
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def list_packages
      raise NotImplementedError
    end

    def install_package_manager
      raise NotImplementedError
    end

    def install_packages(packages = [], opts = {})
      existing_packages = list_packages
      packages.each do |package|
        if !existing_packages.include?(package)
          install_package(package)
          puts "* #{package} - newly installed" if opts[:log_output]
        else
          puts "* #{package} - already installed" if opts[:log_output]
        end
      end
    end

    def package_installed?(package)
      list_packages.include?(package)
    end

    def install_package(package)
      raise NotImplementedError
    end
  end
end
