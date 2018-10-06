require_relative './brew'

class Zsh
  def self.install
    install_oh_my_zsh
    set_default_shell
  end

  def self.install_oh_my_zsh
    if File.exist? File.expand_path("~/.oh-my-zsh")
      system 'upgrade_oh_my_zsh'
    else
      system "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
    end
  end

  def self.set_default_shell
    `sudo sh -c "echo $(which zsh) >> /etc/shells"`
    `chsh -s $(which zsh)` if `echo $SHELL` !~ /^.*zsh/
  end
end
