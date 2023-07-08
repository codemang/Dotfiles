#!/bin/bash

DOTFILES_DIR=../

# https://stackoverflow.com/a/4774063
FULL_PATH_TO_THIS_FILE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function parse_command_line_args() {
  for ARGUMENT in "$@"
  do
     KEY=$(echo $ARGUMENT | cut -f1 -d=)

     KEY_LENGTH=${#KEY}
     VALUE="${ARGUMENT:$KEY_LENGTH+1}"

     export "$KEY"="$VALUE"
  done
}

# function copy_dotfiles() {
    # $COPY_COMMAND $FULL_PATH_TO_THIS_FILE/$local_file_name $DOCKER_CONTAINER_NAME:~/dotfiles/$local_file_name
# }

function gitzip() {
	git archive -o $@.zip HEAD
}

function zip_dotfiles() {
  gitzip dotfiles
}

function install_dotfiles_via_scp() {
  zip_dotfiles > /dev/null
  read -p 'Host name/address (omit any path/destination info): ' scp_destination
  ssh $scp_destination "mkdir -p ~/Dotfiles"
  scp dotfiles.zip $scp_destination:~/Dotfiles/dotfiles.zip > /dev/null
  ssh $scp_destination "sudo apt install unzip > /dev/null 2>&1"
  ssh $scp_destination "unzip -o ~/Dotfiles/dotfiles.zip -d ~/Dotfiles > /dev/null"
  ssh $scp_destination "~/Dotfiles/bin/install_dotfiles.sh"
}

function copy_to_docker_container() {
  parse_command_line_args $@
  docker_container_id=$(docker-compose ps -q $DOCKER_COMPOSE_SERVICE_NAME)

  for local_file_name in $(ls $FULL_PATH_TO_THIS_FILE/../zsh); do
    docker cp $COPY_COMMAND $FULL_PATH_TO_THIS_FILE/../zsh/$local_file_name $docker_container_id:/$local_file_name
    echo "Copied $local_file_name"
  done
  # copy_dotfiles COPY_COMMAND=cp $DOTFILES_DIR/dotfiles/helpers/git.sh
}

# copy_to_docker_container $@
# copy_to_docker_container $@
# zip_dotfiles
install_dotfiles_via_scp
