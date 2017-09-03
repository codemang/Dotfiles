class RubyGems
  def self.list_gems
    `gem list | sed 's/(.*)//'`.split("\n")
  end

  def self.install_gems(gems, opts={})
    existing_gems = opts[:ignore_existing] ? list_gems : []
    gems.each do |gem|
      if !existing_gems.include?(gem)
        install_gem(gem)
      end
    end
  end

  def self.install_gem(gem)
    system("gem install #{gem}")
  end
end
