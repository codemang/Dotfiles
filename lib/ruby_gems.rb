class RubyGems
  def self.list_gems
    `gem list | sed 's/(.*)//'`.split("\n")
  end

  def self.install_gems(gems)
    gems.each do |gem|
      install_gem(gem)
    end
  end

  def self.install_gem(gem)
    system("gem install #{gem}")
  end
end
