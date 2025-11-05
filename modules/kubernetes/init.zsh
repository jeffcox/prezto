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

# Register completions via the central helper (defined in modules/completion).
# If the helper isn't loaded yet (unusual load order), fall back to a
# minimal local generator that mirrors the helper’s behavior (no pipes).
if typeset -f __prezto_register_dynamic_completion >/dev/null 2>&1; then
  __prezto_register_dynamic_completion kubectl "kubectl completion zsh"
  __prezto_register_dynamic_completion helm    "helm completion zsh"
else
  _dyn="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/completions"
  mkdir -p "$_dyn"
  if (( ${+commands[kubectl]} )); then
    [[ ! -s "$_dyn/_kubectl" || ${commands[kubectl]} -nt "$_dyn/_kubectl" ]] && kubectl completion zsh >! "$_dyn/_kubectl" 2>/dev/null
    (( ${fpath[(I)$_dyn]} == 0 )) && fpath=("$_dyn" $fpath)
    autoload -Uz _kubectl; compdef _kubectl kubectl
  fi
  if (( ${+commands[helm]} )); then
    [[ ! -s "$_dyn/_helm" || ${commands[helm]} -nt "$_dyn/_helm" ]] && helm completion zsh >! "$_dyn/_helm" 2>/dev/null
    (( ${fpath[(I)$_dyn]} == 0 )) && fpath=("$_dyn" $fpath)
    autoload -Uz _helm; compdef _helm helm
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
alias wkb='watch -n 5 kubectl'

kbn () {
  kubectl config set-context --current --namespace="$1"
}

zstyle ':prezto:module:contrib-kubernetes' dev-clusters-default 'dev'
