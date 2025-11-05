#
# Provides 'kubectl' aliases and utilities.
#
# Authors:
#   Bruno Miguel Custodio <brunomcustodio@gmail.com>
#   @jeffcox
#

# Return if requirements are not found.
if [[ ! -v commands[kubectl] ]]; then
  return 1
fi

# Add krew to PATH if installed
if [[ -d ${KREW_ROOT:-$HOME/.krew}/bin ]]; then
  path=("${KREW_ROOT:-$HOME/.krew}/bin" "${(@)path}")
fi

# Register completions via the central helper (defined in modules/completion).
if typeset -f __prezto_register_dynamic_completion >/dev/null 2>&1; then
  __prezto_register_dynamic_completion kubectl kubectl completion zsh
  if [[ -v commands[helm] ]]; then
    __prezto_register_dynamic_completion helm helm completion zsh
  fi
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

# Only define watch helper if watch exists (macOS portability).
if [[ -v commands[watch] ]]; then
  alias wkb='watch -n 5 kubectl'
fi

# Safer namespace switcher (guards missing arg).
kbn () {
  if [[ -z "$1" ]]; then
    print -u2 "usage: kbn <namespace>"
    return 1
  fi
  kubectl config set-context --current --namespace="$1"
}

zstyle ':prezto:module:contrib-kubernetes' dev-clusters-default 'dev'
