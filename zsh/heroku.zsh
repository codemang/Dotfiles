alias hurl="heroku info -s | grep web_url | cut -d= -f2"

# Deploy branch supplied as argment to heroku. If no argument, deploy master.
function hpush() {
  if [ -z "$1" ]; then
    git push heroku master
  else
    git push heroku $1:master
  fi
}
