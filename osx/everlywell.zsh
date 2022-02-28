#!/usr/bin/env zsh

function aws_init() {
  aws configure
}

function install_envhelper() {
  # download file && make it executable
  sudo aws s3 cp s3://ew-securebox/bin/envhelper /usr/local/bin/envhelper &&
    sudo chmod 755 /usr/local/bin/envhelper
}

function db_init() {
  # Simple automation for downloading and importing the QA database.
  # Adapted and (arguably) improved from the Confluence documentation
  # here:
  # https://everlyhealth.atlassian.net/wiki/spaces/EN/pages/
  #   196247663/Get+A+Scrubbed+Database+for+Development
  # You should look at that documentation if you are unsure about what
  # is going on here. This script assumes you have the `envhelper`
  # utility installed and configured properly.

  # Also, it will probably wipe out your local `everlywell_qa` database.
  # Be careful. Also, this takes forever.

  if ! command -v envhelper &>/dev/null; then
    echo "You must have $(envhelper) installed first."
    echo "See https://github.com/EverlyWell/envhelper"
    exit
  fi

  connection_string=$(envhelper getDotEnv -e qa -s store | grep -Eo 'postgres://(.*)')

  echo "Fetching remote database. This is gonna take a while..."

  timestamp=$(date +%s)
  outdir="everlywell_qa_$timestamp"

  pg_dump "$connection_string/everlywell_qa" \
    --verbose \
    --jobs 5 \
    --exclude-table-data=versions \
    --format=d \
    --file=$outdir

  echo "Restoring database from $outdir. This is gonna take a while..."

  pg_restore \
    --no-owner \
    --clean \
    --create \
    --verbose \
    --jobs 5 \
    --format=d \
    --dbname=postgres \
    $outdir
}
