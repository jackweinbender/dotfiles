function install_gitlab_runner() {
  # download file && make it executable (ARM only!)
  sudo curl --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-darwin-arm64" &&
    sudo chmod +x /usr/local/bin/gitlab-runner
}

function initialize_gitlab_runner() {
  gitlab-runner install && gitlab-runner start
  echo "You'll probably need to restart for Gitlab Runner to work."
}
