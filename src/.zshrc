typeset -U PATH
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
export CLICOLOR=1
export EDITOR='nvim'
export HOMEBREW_FORBIDDEN_FORMULAE="node npm pip python python3"
export LANG='en_US.UTF-8'
export LSCOLORS='exGxFxDxcxDxDxhbadacec'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/.rd/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

DIRSTACKSIZE=20
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

autoload -Uz add-zsh-hook
typeset prompt_path="" prompt_git=""
_update_prompt() {
  local p="${PWD/#$HOME/~}" i
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
  local output header branch staged="" unstaged="" arrows="" line
  output=$(git status --porcelain -b 2>/dev/null) || { prompt_git=""; return }
  header="${output%%$'\n'*}"
  branch="${header#\#\# }"
  branch="${branch%%...*}"
  [[ "$branch" == "No commits yet on "* ]] && branch="${branch#No commits yet on }"
  [[ "$branch" == "HEAD (no branch)" ]] && branch="detached"
  for line in ${(f)output}; do
    [[ "$line" == "##"* ]] && continue
    [[ -n "$staged" && -n "$unstaged" ]] && break
    [[ "${line[1]}" != " " && "${line[1]}" != "?" ]] && staged="%F{10}+%f"
    [[ "${line[2]}" != " " && "${line[1]}" != "?" ]] && unstaged="%F{11}*%f"
  done
  [[ "$header" == *"behind "* ]] && arrows+="%F{9}⇣%f"
  [[ "$header" == *"ahead "* ]] && arrows+="%F{14}⇡%f"
  prompt_git="%F{5}${branch}%f${staged}${unstaged}${arrows:+ ${arrows}}"
}
add-zsh-hook precmd _update_prompt
PROMPT=$'%F{12}${prompt_path}%f${prompt_git:+\u0020${prompt_git}}\u0020%(?.%f.%F{1})\u276f%f\u0020'

continue-line() { LBUFFER+=$'\\\n\u0020\u0020' }
zle -N continue-line
bindkey '\e[13;2u' continue-line

fzf-ghq() {
  TRAPINT() { :; }
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
  TRAPINT() { :; }
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

fzf-zellij() {
  TRAPINT() { :; }
  local session=$(zellij list-sessions -ns 2>/dev/null | fzf --reverse)
  if [[ -n "$session" ]]; then
    BUFFER="zellij attach ${(q)session}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-zellij
bindkey '^\]^\]' fzf-zellij

if [[ -n "$ZELLIJ" ]]; then
  zellij() {
    case "${1:-}" in
      ""|attach|a|-s|--session) echo "Already inside a Zellij session." >&2; return 1 ;;
      *) command zellij "$@" ;;
    esac
  }
else
  zellij() {
    if [[ $# -eq 0 ]]; then
      local name="${PWD:t}"
      command zellij attach --create "$name"
    else
      command zellij "$@"
    fi
  }
fi

eval "$(mise activate zsh)"
