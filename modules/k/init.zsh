# Quick, dirty, and at least a little Prezto flavored.

source ${ZDOTDIR:-$HOME}/.zprezto/modules/k/external/k.sh

# Check for g/numfmt and enable -h by default since I am a human
if [[ -x $(which gnumfmt 2>/dev/null) ]]; then
  alias k='k -h'
else
  if [[ -x $(which numfmt 2>/dev/null) ]]; then
    alias k='k -h'
  fi
fi

alias ka='k -a'
