export EDITOR='vim'
export LANG='en_US.UTF-8'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/dotfiles/scripts:$PATH"

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

# mise
eval "$(mise activate zsh)"

# Rancher Desktop
export PATH="$HOME/.rd/bin:$PATH"
