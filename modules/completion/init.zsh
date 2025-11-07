#
# Sets completion options.
#
# Authors:
#   Robby Russell <robby@planetargon.com>
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

pmodload helper

# Return if requirements are not found.
if [[ $TERM == 'dumb' ]]; then
  return 1
fi

# Keep $fpath unique and global across modules to prevent duplicates.
typeset -gU fpath

# Add zsh-completions to $fpath.
fpath=(${0:h}/external/src $fpath)

# -- homebrew static completions (macOS only, owned here) --------------------
# prevent with:
#   zstyle ':prezto:module:completion' enable-homebrew-site-functions no
if is-darwin && ( prezto_module_declared homebrew \
  && zstyle -T ':prezto:module:completion' enable-homebrew-site-functions ); then

  local brew_sf="/opt/homebrew/share/zsh/site-functions"
  if [[ -d "$brew_sf" ]] && (( ${fpath[(I)$brew_sf]} == 0 )); then
    fpath=("$brew_sf" $fpath)
  fi
fi


# ------------------------------------------------------------------------------
# Dynamic completion helper for modules that can generate their own completions.
# Usage:
#   __prezto_register_dynamic_completion <cmd> <generator words...>
# Examples:
#   __prezto_register_dynamic_completion kubectl kubectl completion zsh
#   __prezto_register_dynamic_completion uv      uv generate-shell-completion zsh
#   __prezto_register_dynamic_completion uvx     uvx --generate-shell-completion zsh
# Notes:
# - Writes directly to file (no pipes) to avoid SIGPIPE panics in generators.
# - Adds a per-user cache dir to $fpath exactly once.
# - Installs a matching compdef so <cmd> uses its _<cmd> function.
# - Honors:
#     zstyle ':prezto:module:completion' disable-dynamic yes|no
#     zstyle ':prezto:module:completion' debug-dynamic   yes|no
# ------------------------------------------------------------------------------
# -- dynamic completion helper ----------------------------------------------
# usage:
#   __prezto_register_dynamic_completion <cmd> <generator words...>
# notes:
#   * skips generation if any _<cmd> already exists in $fpath
#   * returns 1 if command missing or generator fails

__prezto_register_dynamic_completion() {
  emulate -L zsh
  setopt typeset_silent

  local cmd
  local d
  local dir
  local file
  local fn

  if (( $# <= 2 )); then
    return 1
  fi

  cmd="$1"
  shift

  if zstyle -t ':prezto:module:completion' disable-dynamic; then
    return 0
  fi

  # require command to exist
  if [[ ! -v commands[$cmd] ]]; then
    return 1
  fi

  fn="_${cmd}"

  # if any static _<cmd> exists, prefer it and stop
  for d in $fpath; do
    if [[ -s "$d/$fn" ]]; then
      return 0
    fi
  done

  dir="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/completions"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi

  file="${dir}/${fn}"

  # generate only if missing or older than the binary
  if [[ ! -s "$file" || ${commands[$cmd]} -nt "$file" ]]; then
    "$@" >! "$file" 2>/dev/null || return 1
  fi

  if (( ${fpath[(I)$dir]} == 0 )); then
    fpath=("$dir" $fpath)
  fi

  autoload -Uz "$fn"
  compdef "$fn" "$cmd"

  if zstyle -t ':prezto:module:completion' debug-dynamic; then
    print -r -- "[completion] ${cmd} -> ${file} (fn ${fn})" > /dev/stderr
  fi
}


#
# Options
#

setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.
setopt PATH_DIRS            # Perform path search even on command names with slashes.
setopt AUTO_MENU            # Show completion menu on a successive tab press.
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash.
setopt EXTENDED_GLOB        # Needed for file modification glob modifiers with compinit.
unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry.
unsetopt FLOW_CONTROL       # Disable start/stop characters in shell editor.

#
# Variables
#

# Standard style used by default for 'list-colors'
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

#
# Initialization
#

# Load and initialize the completion system ignoring insecure directories with a
# cache time of 20 hours, so it should almost always regenerate the first time a
# shell is opened each day.
autoload -Uz compinit
local _comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"

if zstyle -t ':prezto:module:completion' strict-audit; then
  # prune insecure dirs silently, then run normal compinit
  local -a bad clean
  bad=(${(f)"$(compaudit 2>/dev/null)"})
  if (( ${#bad} )); then
    local p
    for p in $fpath; do
      if (( ${bad[(I)$p]} == 0 )); then
        clean+=("$p")
      fi
    done
    fpath=("${clean[@]}")
  fi
  if [[ $_comp_path(#qNmh-20) ]]; then
    compinit -C -d "$_comp_path"
  else
    mkdir -p "$_comp_path:h"
    compinit -d "$_comp_path"
    touch "$_comp_path"
  fi
else
  # fast path (original behavior)
  if [[ $_comp_path(#qNmh-20) ]]; then
    compinit -C -d "$_comp_path"
  else
    mkdir -p "$_comp_path:h"
    compinit -i -d "$_comp_path"
    touch "$_comp_path"
  fi
fi
unset _comp_path


#
# Styles
#

# Defaults.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
if zstyle -t ':prezto:module:completion:*' case-sensitive; then
  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  setopt CASE_GLOB
else
  zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}'  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unsetopt CASE_GLOB
fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environment Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion. But allow ignoring custom entries from static
# */etc/hosts* which might be uninteresting.
zstyle -a ':prezto:module:completion:*:hosts' etc-host-ignores '_etc_host_ignores'

zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*' menu yes select
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
