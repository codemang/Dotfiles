alias vup="vagrant up"
alias vdest="vagrant destroy"
alias vprov="vagrant provision"
alias vls="vagrant global-status"
alias vr="vagrant resume"
alias vssh="vagrant ssh"

function vcustomize() {
  # Hidden folder where your files will be temporarily stored.
  VAGRANT_GATEWAY=".nr-custom-files"

  # Move all files you want into the VAGRANT GATEWAY
  echo "Importing custom .bashrc/.vimrc settings into Vagrant machine "
  mkdir -p .nr-custom-files
  cp ~/Dotfiles/vagrant/bashrc_extension $VAGRANT_GATEWAY
  cp ~/Dotfiles/vagrant/vimrc_extension $VAGRANT_GATEWAY
  cp ~/.vim/colors/* $VAGRANT_GATEWAY

  # Generate command to move files from the VAGRANT GATEWAY to the home directory
  # of the VM
  cmd="
  cat /vagrant/$VAGRANT_GATEWAY/bashrc_extension >> ~/.bashrc;
  cat /vagrant/$VAGRANT_GATEWAY/vimrc_extension >> ~/.vimrc;
  mkdir -p ~/.vim/colors;
  cp -r /vagrant/$VAGRANT_GATEWAY/*.vim ~/.vim/colors"

  vagrant ssh -- -t $cmd
  echo "Import complete!"
}
