class Powerfonts
  def self.install
    system('git clone https://github.com/powerline/fonts.git ~/fonts --depth=1')
    system(".#{Dir.home}/fonts/install.sh")
    system('rm -rf ~/fonts')
  end
end
