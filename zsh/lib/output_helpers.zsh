CURSOR='==>'

function warn {
  echo -e "$(yellow $CURSOR) $1"
}

function error {
  echo -e "$(red $CURSOR) $1"
}

function success {
  echo -e "$(green $CURSOR) $1"
}

function info {
  echo -e "$(blue $CURSOR) $1"
}
