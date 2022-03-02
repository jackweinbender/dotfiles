function install_envhelper() {
  # download file && make it executable
  sudo aws s3 cp s3://ew-securebox/bin/envhelper /usr/local/bin/envhelper &&
    sudo chmod 755 /usr/local/bin/envhelper
}
