#!/usr/bin/env bash
set -euo pipefail

as_owner=false
initial_install=false
for arg in "$@"; do
  if [[ $arg == '--as-owner' ]]; then
    as_owner=true
    break
  fi
done

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'

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
  ln -si "$from" "$to" < /dev/tty || :
}

is_owner() {
  if [[ $as_owner == true ]]; then
    return 0
  fi
  [[ $(whoami) == 'hairihou' ]]
}

if [[ ! -e "$dst/.git" ]]; then
  initial_install=true
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
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$dst/src/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"
create_symlink "$dst/src/.config/git/ignore" "$HOME/.config/git/ignore"
create_symlink "$dst/src/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
create_symlink "$dst/src/.zshrc" "$HOME/.zshrc"
if is_owner; then
  create_symlink "$dst/src/.gitconfig" "$HOME/.gitconfig"
fi

if [[ $(uname) == 'Darwin' ]]; then
  if ! xcode-select -p &> /dev/null; then
    echo 'Xcode Command Line Tools are not installed.'
    read -p 'Install them now? (y/N) ' -n 1 -r REPLY < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      xcode-select --install
    fi
  fi

  if is_owner; then
    create_symlink "$dst/src/.config/brew/bundle.rb" "$HOME/.Brewfile"
  else
    create_symlink "$dst/src/.config/brew/bundle.work.rb" "$HOME/.Brewfile"
  fi
  vscode="$HOME/Library/Application Support/Code/User"
  if [[ -d "$vscode" ]]; then
    create_symlink "$dst/src/.vscode/settings.json" "$vscode/settings.json"
    create_symlink "$dst/src/.vscode/mcp.json" "$vscode/mcp.json"
  fi
  if $initial_install; then
    echo 'Configuring macOS...'
    read -p 'Run cdefaults to set up macOS? (y/N) ' -n 1 -r REPLY < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      "$dst/bin/cdefaults"
    fi
  fi
else
  echo "($(uname -a)) is not supported"
fi
