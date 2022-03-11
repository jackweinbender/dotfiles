# Colors
end="\033[0m"
black="\033[0;30m"
blackb="\033[1;30m"
white="\033[0;37m"
whiteb="\033[1;37m"
red="\033[0;31m"
redb="\033[1;31m"
green="\033[0;32m"
greenb="\033[1;32m"
yellow="\033[0;33m"
yellowb="\033[1;33m"
blue="\033[0;34m"
blueb="\033[1;34m"
purple="\033[0;35m"
purpleb="\033[1;35m"
lightblue="\033[0;36m"
lightblueb="\033[1;36m"

function colorize {
  echo -e "${1}$2${end}"
}

function black {
  colorize $black $1
}

function blackb {
  colorize $blackb $1
}

function white {
  colorize $white $1
}

function whiteb {
  colorize $whiteb $1
}

function red {
  colorize $red $1
}

function redb {
  colorize $redb $1
}

function green {
  colorize $green $1
}

function greenb {
  colorize $greenb $1
}

function yellow {
  colorize $yellow $1
}

function yellowb {
  colorize $yellowb $1
}

function blue {
  colorize $blue $1
}

function blueb {
  colorize $blueb $1
}

function purple {
  colorize $purple $1
}

function purpleb {
  colorize $purpleb $1
}

function lightblue {
  colorize $lightblue $1
}

function lightblueb {
  colorize $lightblueb $1
}

function colors {
  black "black"
  blackb "blackb"
  white "white"
  whiteb "whiteb"
  red "red"
  redb "redb"
  green "green"
  greenb "greenb"
  yellow "yellow"
  yellowb "yellowb"
  blue "blue"
  blueb "blueb"
  purple "purple"
  purpleb "purpleb"
  lightblue "lightblue"
  lightblueb "lightblueb"
}
