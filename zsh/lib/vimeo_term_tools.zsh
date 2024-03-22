function gitgrep() {
  echo "Searching for $2 in $1 ..."
  cd $1 && git grep $2
}

function gitgrep_kubernetes() {
  gitgrep ~/vimeows/kubernetes $1
}

function gitgrep_terraform() {
  gitgrep ~/vimeows/terraform $1
}

function gitgrep_user() {
  gitgrep_kubernetes $1
  gitgrep_terraform $1
}

function mailgun_for() {
  open https://app.mailgun.com/app/account/users
}

function ssh_keys_for() {
  open https://dashboard.sre.vimeows.com/sshkeys
}

function terminator() {
  echo "Running terminator for $1"
  gitgrep_user $1

  read -s -k '?Press any key to continue to web services (will open in new tabs)'
  ssh_keys_for $1
  mailgun_for $1

  read -s -k '?Press any key to continue to mysql grants (requires google auth)'
  gcloud auth login && gcloud compute ssh --zone "us-east1-b" "db-mysql-us-east1-a-10" --project "vimeo-infra" --internal-ip --command="pt-show-grants | grep $1"
}
