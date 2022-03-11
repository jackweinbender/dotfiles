function setup_preview_console() {
  aws eks update-kubeconfig --name ew-test-preview-eks-cluster-cluster
}
function get_pods {
  if [ $# -eq 0 ]; then
    namespace=${1:-$(git symbolic-ref --short -q HEAD)}
  else
    namespace=$1
  fi

  info "Searching for store-api pod in namespace ${namespace}..."
  kubectl -n ${namespace} get pods | kubecolor
}

function kubecolor {
  sed "s/Running/$(greenb Running)/"
  sed "s/Pending/$(blue Pending)/"
  sed "s/ContainerCreating/$(blue ContainerCreating)/"
  sed "s/Terminating/$(yellow Terminating)/"
  sed "s/Error/$(red Error)/"
  sed "s/CrashLoopBackOff/$(purple CrashLoopBackOff)/"
  sed "s/ImagePullBackOff/$(purple ImagePullBackOff)/"
}

function preview-console {

  command="rails c"

  if [ $# -eq 0 ]; then
    namespace=${1:-$(git symbolic-ref --short -q HEAD)}
  else
    namespace=$1
  fi

  pod=$(get_pods $namespace | grep -Eo 'store-api-\S+')

  success "Pod ${pod} found."
  info "Starting rails-console..."

  eval "kubectl -n ${namespace} exec -it ${pod} -- ${command}"
}
