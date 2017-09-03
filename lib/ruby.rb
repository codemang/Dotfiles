class Ruby
  RUBY_VERSION = '2.4.1'

  def self.install
    rbenv_init
    rbenv_doctor
    create_global_ruby_version
    install_ruby
  end

  private

  def self.rbenv_doctor
    `curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash`
  end

  def self.rbenv_init
    `rbenv init`
  end

  def self.create_global_ruby_version
    version_file = File.open(File.expand_path('~/.rbenv/version'), 'w')
    version_file.truncate(0)
    version_file.write(RUBY_VERSION)
  end

  def self.install_ruby
    `rbenv install #{RUBY_VERSION}`
  end
end
