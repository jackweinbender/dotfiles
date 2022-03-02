function setup_preview_console() {
  aws eks update-kubeconfig --name ew-test-preview-eks-cluster-cluster
}

function preview-console {
  namespace=${1:-$(git symbolic-ref --short -q HEAD)}
  echo "Searching for store-api pod in namespace ${namespace}..."

  pod=$(kubectl -n ${namespace} get pods | grep -Eo 'store-api-\S+')
  echo "Pod ${pod} found."

  command="rails c"

  echo "Starting rails-console..."

  eval "kubectl -n ${namespace} exec -it ${pod} -- ${command}"
}