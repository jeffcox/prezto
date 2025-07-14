#
# Provides 'kubectl' aliases and utiities.
#
# Authors:
#   Bruno Miguel Custodio <brunomcustodio@gmail.com>
#

# Return if requirements are not found.
if (( ! ${+commands[kubectl]} )); then
  return 1
fi

# Add krew to PATH if installed
if [[ -d ${KREW_ROOT:-$HOME/.krew}/bin ]]; then
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

cache_completion () {
  local cmd="$1"
  local cache_file="${0:h}/cache-${cmd}.zsh"
  local bin="${commands[$cmd]}"

  if [[ -z "$bin" ]]; then
    return
  fi

  if [[ "${bin}" -nt "${cache_file}" || ! -s "${cache_file}" ]]; then
    $bin completion zsh >! "${cache_file}" 2>/dev/null
  fi

  source "${cache_file}"
}

cache_completion kubectl
cache_completion helm


#
# Aliases
#

alias kb='kubectl'

alias kba='kubectl apply'
alias kbc='kubectl config'
alias kbcg='kubectl config get-contexts'
alias kbcu='kubectl config use-context'
alias kbcv='kubectl config view'
alias kbC='kubectl create'
alias kbD='kubectl delete'
alias kbd='kubectl describe'
alias kbe='kubectl exec'
alias kbf='kubectl port-forward'
alias kbg='kubectl get'
alias kbl='kubectl logs'
alias kblf='kubectl logs --follow'
alias kbr='kubectl run'

alias wkb='watch -n 5 kubectl'

kbn () {
  kubectl config set-context --current --namespace=$1
}

# name formatting
zstyle ':prezto:module:contrib-kubernetes' dev-clusters-default 'dev'
