#!/usr/bin/env bash
set -euo pipefail

create_symlink() {
    local src="$1"
    local target="$2"
    local dir="$(dirname "$target")"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        echo "Symlink already exists: $target -> $src"
        return 0
    fi
    if [ "$dir" != "$HOME" ] && [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
    ln -si "$src" "$target" < /dev/tty || :
}

readonly dest="$HOME/dotfiles"
readonly repo='https://github.com/hairihou/dotfiles.git'

if [ ! -e "$dest/.git" ]; then
  git clone "$repo" "$dest"
else
  if [ "$(git -C "$dest" config --get remote.origin.url)" != "$repo" ]; then
    echo "Error: Remote origin URL does not match expected URL"
    exit 1
  fi

  echo "Updating existing repository..."
  git -C "$dest" fetch --prune
  git -C "$dest" switch main
  git -C "$dest" pull origin main
fi

echo "Creating symlinks..."
if [ "$(whoami)" == 'hairihou' ]; then
  create_symlink "$dest/src/.gitconfig" "$HOME/.gitconfig"
fi
create_symlink "$dest/src/.config/git/ignore" "$HOME/.config/git/ignore"
create_symlink "$dest/src/.zshrc" "$HOME/.zshrc"

if [ "$(uname)" == 'Darwin' ]; then
  vscode="$HOME/Library/Application Support/Code/User"
  if [ -d "$vscode" ]; then
    create_symlink "$dest/src/.vscode/settings.json" "$vscode/settings.json"
    create_symlink "$dest/src/.vscode/mcp.json" "$vscode/mcp.json"
  fi
else
  echo "($(uname -a)) is not supported"
fi
