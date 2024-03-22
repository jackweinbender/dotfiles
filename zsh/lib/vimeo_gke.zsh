all_contexts() {
  for project in $(gcloud projects list --format="value(projectId)" | grep -v "sys-"); do
    # echo "Project: $project"
    clusters_for_project $project
  done
}

private_cluster_creds() {
  echo $1 | awk '{ print "gcloud container clusters --project=" $1 " --location="$3 " get-credentials --internal-ip " $2 }' | sh
}

public_cluster_creds() {
  echo $1 | awk '{ print "gcloud container clusters --project=" $1 " --location="$3 " get-credentials " $2 }' | sh
}

clusters_for_project() {
  IFS=$'\n'
  for cluster in $(gcloud container clusters list --project=$1 --format="value[separator=' '](name,location)" 2>/dev/null); do
    echo "$1 $cluster"
    private_cluster_creds "$1 $cluster" || echo "Retrying for public control plane:" && public_cluster_creds "$1 $cluster"
  done
}
