export EDITOR='vim'
export LANG='en_US.UTF-8'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

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
setopt SHARE_HISTORY
setopt IGNOREEOF

autoload -Uz compinit
compinit

# pure
autoload -U promptinit
promptinit
prompt pure

# peco
peco-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-history
bindkey '^r' peco-history

peco-ghq() {
  local repo=$(ghq list --full-path | peco)
  if [[ -n "$repo" ]]; then
    cd "$repo"
  fi
  zle reset-prompt
}
zle -N peco-ghq
bindkey '^g' peco-ghq

# mise
eval "$(mise activate zsh)"

# Rancher Desktop
export PATH="$HOME/.rd/bin:$PATH"
