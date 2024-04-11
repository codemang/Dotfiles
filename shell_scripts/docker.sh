alias dc="docker-compose"
alias dcb="docker-compose build"
function dcd() {
  if [ $# -eq 0 ]; then
    docker-compose down # Stop all containers
  else
    docker-compose rm -s -v $1 # Stop a single container
  fi
}

alias dcu="docker-compose up"
alias dcl="docker-compose logs -f"
alias dcr="docker-compose run --rm --use-aliases"
alias dce="docker-compose exec"
alias dcrp="docker-compose run --rm --service-ports"
alias dcps="docker-compose ps"
alias rdocker="sudo service docker start"

alias dm="docker-machine"

dk() {
  docker kill $(docker ps -q)
}

dr() {
  docker rm $(docker ps -a -q)
}

derrors() {
  # https://stackoverflow.com/a/55990412
  container_name=$(docker inspect -f '{{.Name}}' $(docker-compose ps -q $1) | cut -c2-)

  docker inspect --format "{{json .State.Health }}" $container_name | jq
}

cdocker() {
  docker volume rm $(docker volume ls -qf dangling=true)
  docker rmi $(docker images | awk '/^<none>/ {print $3}')
}
