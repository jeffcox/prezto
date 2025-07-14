#
# Provides 'kubectl' aliases and utiities.
#
# Authors:
#   Bruno Miguel Custodio <brunomcustodio@gmail.com>
#   @jeffcox
#

# Return if requirements are not found.
if (( ! ${+commands[kubectl]} )); then
  return 1
fi

# Add krew to PATH if installed
if [[ -d ${KREW_ROOT:-$HOME/.krew}/bin ]]; then
  path=("${KREW_ROOT:-$HOME/.krew}/bin" "${(@)path}")
fi

# Use prezto standard cache directory for completions
_dynamic_completion_dir="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/completions"
mkdir -p "${_dynamic_completion_dir}"

load_completion () {
  local cmd="$1"
  local fn="_${cmd}"
  local completion_file="${_dynamic_completion_dir}/${fn}"

  if (( ! ${+commands[$cmd]} )); then
    return
  fi

  # Generate completion file if missing or stale
  if [[ ! -s "${completion_file}" || ${commands[$cmd]} -nt "${completion_file}" ]]; then
    $cmd completion zsh >! "${completion_file}" 2>/dev/null
  fi

  # Add to fpath and autoload
  if [[ -s "${completion_file}" ]]; then
    fpath=("${_dynamic_completion_dir}" $fpath)
    autoload -Uz "${fn}"
  fi
}

# Hook up completions
load_completion kubectl
load_completion helm

# Only run compinit once
if [[ -z "$_compinit_done" ]]; then
  autoload -Uz compinit
  zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
  compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
  _compinit_done=1
fi

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
  kubectl config set-context --current --namespace="$1"
}

zstyle ':prezto:module:contrib-kubernetes' dev-clusters-default 'dev'
