#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'

sync_repo() {
  if [ ! -e "$dst/.git" ]; then
    git clone "$src" "$dst"
  elif [ "$(git -C "$dst" config --get remote.origin.url)" != "$src" ]; then
    echo 'Error: Remote origin URL does not match expected URL'
    exit 1
  else
    echo 'Updating existing repository...'
    git -C "$dst" fetch --prune
    git -C "$dst" switch main
    git -C "$dst" pull origin main
  fi
}

main() {
  sync_repo
  "$dst/bin/linkup"
}

main
