function warn {
  echo -e "${yellow}>>${end} ${1}"
}

function error {
  echo -e "${red}>>${end} ${1}"
}

function success {
  echo -e "${green}>>${end} ${1}"
}

function info {
  echo -e "${blue}>>${end} ${1}"
}
