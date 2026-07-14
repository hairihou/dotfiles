typeset -U PATH
export CLICOLOR=1
export EDITOR='nvim'
export HOMEBREW_FORBIDDEN_FORMULAE="node npm pip pip3 python python3"
export LANG='en_US.UTF-8'
export LSCOLORS='exGxFxDxcxDxDxhbadacec'

export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

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

fpath=("$HOME/.zsh/completions" $fpath)
autoload -U compinit
zcd=(~/.zcompdump(N.mh+24))
if (( $#zcd )); then
  compinit
else
  compinit -C
fi
unset zcd
LISTMAX=0

autoload -U add-zsh-hook
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
  [[ "$header" == *"behind "* ]] && arrows+="%F{9}"$'\u21e3'"%f"
  [[ "$header" == *"ahead "* ]] && arrows+="%F{14}"$'\u21e1'"%f"
  prompt_git="%F{5}${branch}%f${staged}${unstaged}${arrows:+ ${arrows}}"
}
add-zsh-hook precmd _update_prompt
PROMPT=$'%F{12}${prompt_path}%f${prompt_git:+\u0020${prompt_git}}\u0020%F{8}\u276f%f\u0020'

fzf-ghq() {
  TRAPINT() { :; }
  local repo=$(ghq list --full-path | fzf --layout=reverse)
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
  local selected=$(fc -lrn 1 | fzf --layout=reverse --no-sort --query "$LBUFFER")
  if [[ -n "$selected" ]]; then
    print -s "$selected"
    BUFFER="$selected"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N fzf-history
bindkey '^r' fzf-history

fzf-tmux-attach() {
  TRAPINT() { :; }
  local fmt="#{session_name}	"$'\e[38;5;8m'"#{pane_current_path}"$'\e[m'
  local selected=$(tmux list-sessions -F "$fmt" 2>/dev/null | fzf --layout=reverse --ansi --tabstop=16)
  local session="${selected%%	*}"
  if [[ -n "$session" ]]; then
    BUFFER="tmux attach -t ${(q)session}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-tmux-attach
bindkey '^\]^\]' fzf-tmux-attach

eval "$(mise activate zsh)"

if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2mCompleting %d\e[m'
zstyle ':completion:*' menu select
source <(carapace _carapace)

[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
