#
# Completions for uv and uvx (uvx is an alias for `uv tool run`).
#

# Return non-zero if uv is not present (uv/uvx ship together in your env).
if [[ ! -v commands[uv] ]]; then
  return 1
fi

# Register completions via the central helper (defined in modules/completion).
if typeset -f __prezto_register_dynamic_completion >/dev/null 2>&1; then
  __prezto_register_dynamic_completion uv  uv  generate-shell-completion zsh
  if [[ -v commands[uvx] ]]; then
    __prezto_register_dynamic_completion uvx uvx --generate-shell-completion zsh
  fi
fi
