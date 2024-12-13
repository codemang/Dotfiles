class Ruby
  # Depends on chruby and ruby-install being installed
  def self.install
    system("ruby-install ruby")
    `echo $(ls ~/.rubies | head) > ~/.ruby-version`
  end
end
