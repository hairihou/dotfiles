#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'
readonly as_owner="$([[ $(whoami) == 'hairihou' ]] && echo 'true' || echo 'false')"

create_symlink() {
  local from="$1"
  local to="$2"
  local parent="$(dirname "$to")"

  if [[ -L "$to" && "$(readlink "$to")" = "$from" ]]; then
    return 0
  fi

  if [[ "$parent" != "$HOME" && ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  if [[ -d "$from" ]]; then
    if [[ -e "$to" || -L "$to" ]]; then
      echo -n "ln: replace '$to'? "
      read -r response < /dev/tty
      if [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        rm -rf "$to"
      else
        return 0
      fi
    fi
    ln -s "$from" "$to" < /dev/tty || :
  elif [[ -f "$from" ]]; then
    ln -sfi "$from" "$to" < /dev/tty || :
  else
    return 0
  fi
}

if [[ ! -e "$dst/.git" ]]; then
  git clone "$src" "$dst"
elif [[ "$(git -C "$dst" config --get remote.origin.url)" != "$src" ]]; then
  echo 'Error: Remote origin URL does not match expected URL'
  exit 1
else
  echo 'Updating existing repository...'
  git -C "$dst" fetch --prune
  git -C "$dst" switch main
  git -C "$dst" pull origin main
fi

echo 'Creating symlinks...'
create_symlink "$dst/src/.claude/agents" "$HOME/.claude/agents"
create_symlink "$dst/src/.claude/commands" "$HOME/.claude/commands"
create_symlink "$dst/src/.claude/commands" "$HOME/.codex/prompts"
create_symlink "$dst/src/.claude/skills" "$HOME/.claude/skills"
create_symlink "$dst/src/.claude/skills" "$HOME/.codex/skills"
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"
create_symlink "$dst/src/.claude/settings.json" "$HOME/.claude/settings.json"
create_symlink "$dst/src/.config/git/ignore" "$HOME/.config/git/ignore"
create_symlink "$dst/src/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
create_symlink "$dst/src/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
create_symlink "$dst/src/.zshrc" "$HOME/.zshrc"

if [[ $(uname) == 'Darwin' ]]; then
  if [[ "$as_owner" == 'true' ]]; then
    create_symlink "$dst/src/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$dst/src/.config/brew/.Brewfile.owner" "$HOME/.Brewfile"
  else
    create_symlink "$dst/src/.config/brew/.Brewfile" "$HOME/.Brewfile"
  fi
  vscode="$HOME/Library/Application Support/Code/User"
  if [[ -d "$vscode" ]]; then
    create_symlink "$dst/src/.github/instructions" "$vscode/prompts"
    create_symlink "$dst/src/.vscode/settings.json" "$vscode/settings.json"
  fi
else
  echo "($(uname -a)) is not supported"
fi
