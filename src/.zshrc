typeset -U PATH
export EDITOR='vim'
export LANG='en_US.UTF-8'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt IGNOREEOF
setopt PROMPT_SUBST

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

autoload -Uz vcs_info
precmd() {
  if [[ -d .git ]] || git rev-parse --git-dir &>/dev/null; then
    vcs_info
  else
    vcs_info_msg_0_=""
  fi
}
zstyle ':vcs_info:git:*' formats '%b'
PROMPT='%F{blue}%~%f %F{magenta}${vcs_info_msg_0_}%f
'$'\u276f'' '

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# fzf
export FZF_DEFAULT_OPTS='--color=hl:blue,hl+:cyan,pointer:cyan,marker:cyan --reverse'

fzf-history() {
  local selected=$(fc -ln 1 | fzf --query "$LBUFFER" --tac)
  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N fzf-history
bindkey '^r' fzf-history

fzf-ghq() {
  local repo=$(ghq list --full-path | fzf)
  if [[ -n "$repo" ]]; then
    BUFFER="cd ${(q)repo}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-ghq
bindkey '^g' fzf-ghq

# mise
eval "$(mise activate zsh)"

# Rancher Desktop
export PATH="$HOME/.rd/bin:$PATH"
