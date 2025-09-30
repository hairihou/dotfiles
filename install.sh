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

  if [[ -d "$to" && ! -L "$to" ]]; then
    local backup_path="${to}.backup"
    rm -rf "$backup_path"
    mv "$to" "$backup_path"
  elif [[ -e "$to" ]]; then
    echo -n "Overwrite $to? (y/N): "
    read -r response < /dev/tty
    if [[ "$response" =~ ^[Yy]$ ]]; then
      rm "$to"
    else
      echo "Skipped $to"
      return 0
    fi
  fi

  ln -s "$from" "$to"
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
create_symlink "$dst/src/.claude/commands" "$HOME/.claude/commands"
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"
create_symlink "$dst/src/.config/git/ignore" "$HOME/.config/git/ignore"
create_symlink "$dst/src/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
create_symlink "$dst/src/.zshrc" "$HOME/.zshrc"
if [[ "$as_owner" == 'true' ]]; then
  create_symlink "$dst/src/.gitconfig" "$HOME/.gitconfig"
fi

if [[ $(uname) == 'Darwin' ]]; then
  if [[ "$as_owner" == 'true' ]]; then
    create_symlink "$dst/src/.config/brew/.Brewfile.owner" "$HOME/.Brewfile"
  else
    create_symlink "$dst/src/.config/brew/.Brewfile" "$HOME/.Brewfile"
  fi
  vscode="$HOME/Library/Application Support/Code/User"
  if [[ -d "$vscode" ]]; then
    create_symlink "$dst/src/.vscode/settings.json" "$vscode/settings.json"
    create_symlink "$dst/src/.vscode/mcp.json" "$vscode/mcp.json"
  fi
else
  echo "($(uname -a)) is not supported"
fi
