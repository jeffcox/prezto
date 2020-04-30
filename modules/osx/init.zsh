#
# Defines macOS aliases and functions.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
pmodload 'helper'

# Return if requirements are not found.
if ! is-darwin; then
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

# Add an alias to turn on the SOCKS proxy
alias sockson='networksetup -setsocksfirewallproxystate "Wi-Fi" on'
alias socksoff='networksetup -setsocksfirewallproxystate "Wi-Fi" off'
alias socksquery='networksetup -getsocksfirewallproxy "Wi-Fi"'
alias serviceorder='networksetup -listnetworkserviceorder | grep "\([0-9]\)" | grep -v Port | cut -d " " -f 2'

alias flushdns='sudo killall -HUP mDNSResponder'

# Fix 'Open With' being slow/not working
# alias fixopenw='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
