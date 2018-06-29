#
# Defines macOS aliases and functions.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Return if requirements are not found.
if [[ "$OSTYPE" != darwin* ]]; then
  return 1
fi

#
# Aliases
#

# Changes directory to the current Finder directory.
alias cdf='cd "$(pfd)"'

# Pushes directory to the current Finder directory.
alias pushdf='pushd "$(pfd)"'

# Start and stop tftpd
alias tftpd.start='sudo launchctl load -w /System/Library/LaunchDaemons/tftp.plist'
alias tftpd.stop='sudo launchctl unload -w /System/Library/LaunchDaemons/tftp.plist'

# Add an alias to open with Xmplify
alias xmpl='open -a /Applications/Xmplify.app'
