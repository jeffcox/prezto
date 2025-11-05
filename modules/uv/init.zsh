#
# Completions for uv and uvx (uvx is an alias for `uv tool run`).
#

# Return if neither uv nor uvx is present.
if (( ! ${+commands[uv]} )); then
  return 1
fi

# Prefer central helper; otherwise fallback quietly.
if typeset -f __prezto_register_dynamic_completion >/dev/null 2>&1; then
  (( ${+commands[uv]}  ))  && __prezto_register_dynamic_completion uv  "uv generate-shell-completion zsh"
  (( ${+commands[uvx]} )) && __prezto_register_dynamic_completion uvx "uvx --generate-shell-completion zsh"
else
  _dyn="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/completions"
  mkdir -p "$_dyn"
  if (( ${+commands[uv]} )); then
    [[ ! -s "$_dyn/_uv"  || ${commands[uv]}  -nt "$_dyn/_uv"  ]] && uv  generate-shell-completion zsh >! "$_dyn/_uv"  2>/dev/null
    (( ${fpath[(I)$_dyn]} == 0 )) && fpath=("$_dyn" $fpath)
    autoload -Uz _uv;  compdef _uv  uv
  fi
  if (( ${+commands[uvx]} )); then
    [[ ! -s "$_dyn/_uvx" || ${commands[uvx]} -nt "$_dyn/_uvx" ]] && uvx --generate-shell-completion zsh >! "$_dyn/_uvx" 2>/dev/null
    (( ${fpath[(I)$_dyn]} == 0 )) && fpath=("$_dyn" $fpath)
    autoload -Uz _uvx; compdef _uvx uvx
  fi
fi
