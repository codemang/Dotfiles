class Ruby
  # Depends on chruby and ruby-install being installed
  def self.install
    system('ruby-install ruby')

    latest_ruby = `ls ~/.rubies`
      .split("\n")
      .map(&:strip)
      .sort_by{ |ruby_version| ruby_version }
      .last

    `echo #{latest_ruby} > ~/.ruby-version`
  end
end
