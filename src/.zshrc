typeset -U PATH
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export EDITOR='nvim'
export HOMEBREW_FORBIDDEN_FORMULAE="node npm pip python python3"
export LANG='en_US.UTF-8'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.rd/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

DIRSTACKSIZE=20
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt AUTO_CD
setopt AUTO_PUSHD
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt IGNOREEOF
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS
setopt SHARE_HISTORY

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

autoload -Uz add-zsh-hook vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}+%f'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}*%f'
zstyle ':vcs_info:git:*' formats '%F{magenta}%b%f%u%c'
typeset prompt_path=""
_update_prompt() {
  local p="${PWD/#$HOME/~}" lr behind ahead arrows i
  local -a parts
  if [[ "$p" == "/" ]]; then
    prompt_path="/"
  else
    parts=("${(@s:/:)p}")
    prompt_path=""
    for ((i=1; i<${#parts[@]}; i++)); do
      prompt_path+="${parts[i]:0:1}/"
    done
    prompt_path+="${parts[-1]}"
  fi
  if git rev-parse --git-dir &>/dev/null; then
    vcs_info
    lr=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
    behind=${lr%%$'\t'*}
    ahead=${lr##*$'\t'}
    arrows=""
    [[ $behind -gt 0 ]] && arrows+="%F{red}⇣%f"
    [[ $ahead -gt 0 ]] && arrows+="%F{cyan}⇡%f"
    [[ -n $arrows ]] && vcs_info_msg_0_="${vcs_info_msg_0_} ${arrows}"
  else
    vcs_info_msg_0_=""
  fi
}
add-zsh-hook precmd _update_prompt
PROMPT='%F{blue}${prompt_path}%f${vcs_info_msg_0_:+ ${vcs_info_msg_0_}} %(?.%f.%F{red})❯%f '

continue-line() { LBUFFER+=$'\\\n\u0020\u0020' }
zle -N continue-line
bindkey '\e[13;2u' continue-line

fzf-ghq() {
  local repo=$(ghq list --full-path | fzf --reverse)
  if [[ -n "$repo" ]]; then
    BUFFER="cd ${(q)repo}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-ghq
bindkey '^\]' fzf-ghq

fzf-history() {
  local selected=$(fc -ln 1 | fzf --no-sort --query "$LBUFFER" --reverse --tac)
  if [[ -n "$selected" ]]; then
    print -s "$selected"
    BUFFER="$selected"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N fzf-history
bindkey '^r' fzf-history

eval "$(mise activate zsh)"
