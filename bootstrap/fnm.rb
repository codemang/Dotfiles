class Fnm
  def self.install
    # Install the stable version of Node.
    system('fnm install --lts')
  end
end
