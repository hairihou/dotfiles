#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'
readonly as_owner="$([[ $(whoami) == 'hairihou' ]] && echo 'true' || echo 'false')"

create_symlink() {
  local from="$1"
  local to="$2"
  local parent="$(dirname "$to")"

  if [[ -f "$from" && -L "$to" && "$(readlink "$to")" = "$from" ]]; then
    return 0
  fi

  if [[ "$parent" != "$HOME" && ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  if [[ -d "$from" ]]; then
    [[ -L "$to" ]] && rm "$to"
    mkdir -p "$to"
    for file in "$from"/*; do
      [[ -e "$file" ]] || continue
      create_symlink "$file" "$to/$(basename "$file")"
    done
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

apply_dir() {
  for item in "$1"/{.*,*}; do
    local name="$(basename "$item")"
    [[ "$name" =~ ^\.\.?$ ]] && continue
    [[ -n "${2:-}" && "$name" =~ $2 ]] && continue
    create_symlink "$item" "$HOME/$name"
  done
}

echo 'Creating symlinks...'
apply_dir "$dst/src" "^(darwin|owner|assets)$"
[[ $(uname) == 'Darwin' ]] && apply_dir "$dst/src/darwin"
[[ "$as_owner" == 'true' ]] && apply_dir "$dst/src/owner"
