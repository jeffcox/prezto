#
# Defines MacPorts aliases and adds MacPorts directories to path variables.
#
# Authors:
#   Matt Cable <wozz@wookie.net>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
pmodload 'helper'

# Return if requirements are not found.
if ! is-darwin; then
  return 1
fi

#
# Paths
#

# Set the list of directories that Zsh searches for programs.
path=(
  /opt/local/{bin,sbin}
  $path
)

#
# Aliases
#

alias portc='sudo port clean --all installed'
alias porti='sudo port install'
alias ports='port search'
alias portU='sudo port selfupdate && sudo port upgrade outdated'
alias portu='sudo port upgrade'
alias portX='sudo port -u uninstall'
alias portx='sudo port uninstall'

#
# Use pbzip2 if present for faster archiving
#

if [[ -x $(which pbzip2 2>/dev/null) ]]; then
  alias bzip2=pbzip2
  alias bunzip2=pbunzip2
fi

# Macports Postgres control
# alias postgres.start='sudo launchctl start org.macports.postgresql94-server'
# alias postgres.stop='sudo launchctl stop org.macports.postgresql94-server'
# alias postgres.restart='postgres.stop && postgres.start'
