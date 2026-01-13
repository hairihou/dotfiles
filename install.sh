#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'

is_owner() {
  [[ $(whoami) == 'hairihou' ]]
}

resolve_symlink() {
  local link="$1"
  local target
  target="$(readlink "$link")"
  if [[ "$target" == /* ]]; then
    echo "$target"
  else
    local dir
    dir="$(cd "$(dirname "$link")" && pwd -P)"
    echo "$dir/$target"
  fi
}

sync_repo() {
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
}

create_symlink() {
  local from="$1"
  local to="$2"
  local parent
  parent="$(dirname "$to")"

  if [[ -f "$from" && -L "$to" && "$(resolve_symlink "$to")" == "$from" ]]; then
    return 0
  fi

  if [[ "$parent" != "$HOME" && ! -d "$parent" ]]; then
    mkdir -p "$parent"
  fi

  if [[ -d "$from" ]]; then
    [[ -L "$to" ]] && rm "$to"
    mkdir -p "$to"
    while IFS= read -r -d '' file; do
      create_symlink "$file" "$to/$(basename "$file")"
    done < <(find "$from" -maxdepth 1 -mindepth 1 -print0)
  elif [[ -f "$from" ]]; then
    if ! ln -sfi "$from" "$to" < /dev/tty; then
      echo "Warning: Failed to create symlink: $to" >&2
    fi
  fi
}

apply_dir() {
  local dir="$1"
  local exclude="${2:-}"
  while IFS= read -r -d '' item; do
    local name
    name="$(basename "$item")"
    [[ -n "$exclude" && "$name" =~ $exclude ]] && continue
    create_symlink "$item" "$HOME/$name"
  done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0)
}

main() {
  sync_repo

  echo 'Creating symlinks...'
  apply_dir "$dst/src" '^(darwin|owner|assets)$'
  [[ $(uname) == 'Darwin' ]] && apply_dir "$dst/src/darwin"
  is_owner && apply_dir "$dst/src/owner"
}

main
