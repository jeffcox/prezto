#
# Load Deer Module
#

source ${ZDOTDIR:-$HOME}/.zprezto/modules/deer/external/deer
zle -N deer
bindkey '\ek' deer

zstyle ':deer:' height 23
