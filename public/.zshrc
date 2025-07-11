export EDITOR='vim'
export LANG='en_US.UTF-8'

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt IGNOREEOF

autoload -Uz compinit
compinit

# pure
autoload -U promptinit
promptinit
prompt pure

# peco
peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey "^r" peco-select-history

resize() {
  local scale=${1:-1}
  if ! [[ "$scale" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    echo "Error: Scale must be a number" >&2
    return 1
  fi
  if (($(awk "BEGIN {print ($scale < 1)}"))); then
    scale=1
  elif (($(awk "BEGIN {print ($scale > 3)}"))); then
    scale=3
  fi
  local rows=$((24 * scale))
  local cols=$((80 * scale))
  printf '\e[8;%d;%dt' "$rows" "$cols"
}

# Android
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/tools:$PATH"

# Java
export JAVA_HOME="$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# mise
eval "$(mise activate zsh)"

# Rancher Desktop
export PATH="$HOME/.rd/bin:$PATH"
