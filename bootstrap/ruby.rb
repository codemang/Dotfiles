class Ruby
  DEFAULT_RUBY_VERSION = '2.7.2'
  # Depends on chruby and ruby-install being installed
  def self.install
    system("ruby-install ruby #{DEFAULT_RUBY_VERSION}")
    `echo #{DEFAULT_RUBY_VERSION} > ~/.ruby-version`
  end
end
