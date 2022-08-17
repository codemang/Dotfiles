alias dc="docker-compose"
alias dcb="docker-compose build"
alias dcd="docker-compose down"
alias dcu="docker-compose up"
alias dcl="docker-compose logs -f"
alias dcr="docker-compose run --rm --use-aliases"
alias dcrp="docker-compose run --rm --service-ports"

alias dm="docker-machine"

dk() {
  docker kill $(docker ps -q)
}

dr() {
  docker rm $(docker ps -a -q)
}
