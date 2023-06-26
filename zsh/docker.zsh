alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcd="docker-compose down"
alias dcu="docker-compose up"
alias dcl="docker-compose logs -f"
alias dcr="docker-compose run --rm --use-aliases"
alias dce="docker-compose exec"
alias dcrp="docker-compose run --rm --service-ports"
alias dcps="docker-compose ps"
alias dm="docker-machine"

function dk() {
  docker kill $(docker ps -q)
}

function dr() {
  docker rm $(docker ps -a -q)
}

function derrors() {
  # https://stackoverflow.com/a/55990412
  container_name=$(docker inspect -f '{{.Name}}' $(docker-compose ps -q $1) | cut -c2-)

  docker inspect --format "{{json .State.Health }}" $container_name | jq
}
