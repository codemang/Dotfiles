class Ruby
  RUBY_VERSION = '2.4.1'

  def self.install
    rbenv_init
    install_ruby
    create_global_ruby_version
  end

  private

  def self.rbenv_init
    system("rbenv init")
  end

  def self.install_ruby
    if !(system("rbenv global") == RUBY_VERSION)
      system("rbenv install #{RUBY_VERSION}")
    end
  end

  def self.create_global_ruby_version
    version_file = File.open(File.expand_path('~/.rbenv/version'), 'w')
    version_file.truncate(0)
    version_file.write(RUBY_VERSION)
  end
end
