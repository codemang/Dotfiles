class Ruby
  DEFAULT_RUBY_VERSION = '3.3.6'.freeze

  # Depends on chruby and ruby-install being installed
  def self.install
    system("ruby-install ruby #{DEFAULT_RUBY_VERSION}")
    `echo #{DEFAULT_RUBY_VERSION} > ~/.ruby-version`
  end
end
