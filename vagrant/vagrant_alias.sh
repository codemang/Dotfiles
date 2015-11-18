# OPTIONS=`vagrant ssh-config | awk -v ORS=' ' 'NF {print "-o " $1 "=" $2}'`
# FILES='bashrc_extension bashrc_extension'
# scp $OPTIONS ~/Dotfiles/vagrant/bashrc_extension vagrant@127.0.0.1:~ || echo "Transfer failed!"
# cat ~/Dotfiles/vagrant/bashrc_extension| ssh -p 2200 vagrant@127.0.0.1 "cat >> /home/vagrant/.bashrc"

function vcust() {
  echo "SDF"
  mkdir -p .nr-custom-files
  cp ~/Dotfiles/vagrant/bashrc_extension .nr-custom-files
  cp ~/Dotfiles/vagrant/vimrc_extension .nr-custom-files
  cp ~/.vim/colors/* .nr-custom-files

  cmd="
  cat /vagrant/.nr-custom-files/bashrc_extension >> ~/.bashrc; 
  cat /vagrant/.nr-custom-files/vimrc_extension >> ~/.vimrc;
  mkdir -p ~/.vim/colors;
  cp -r /vagrant/.nr-custom-files/*.vim ~/.vim/colors"
  vagrant ssh -- -t $cmd
}
