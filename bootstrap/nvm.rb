class Nvm
  DEFAULT_NODE_VERSION = '14.16.0'

  def self.install
    system('curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash')
    system("[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\" && nvm install #{DEFAULT_NODE_VERSION}")
  end
end
