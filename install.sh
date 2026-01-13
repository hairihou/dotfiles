#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'

is_owner() {
  [ "$(whoami)" = 'hairihou' ]
}

resolve_symlink() {
  link="$1"
  target="$(readlink "$link")"
  case "$target" in
    /*)
      echo "$target"
      ;;
    *)
      dir="$(cd "$(dirname "$link")" && pwd -P)"
      echo "$dir/$target"
      ;;
  esac
}

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

create_symlink() {
  from="$1"
  to="$2"
  parent="$(dirname "$to")"

  if [ -f "$from" ] && [ -L "$to" ] && [ "$(resolve_symlink "$to")" = "$from" ]; then
    return 0
  fi

  if [ "$parent" != "$HOME" ] && [ ! -d "$parent" ]; then
    mkdir -p "$parent"
  fi

  if [ -d "$from" ]; then
    [ -L "$to" ] && rm "$to"
    mkdir -p "$to"
    find "$from" -maxdepth 1 -mindepth 1 | while IFS= read -r file; do
      create_symlink "$file" "$to/$(basename "$file")"
    done
  elif [ -f "$from" ]; then
    if ! ln -sfi "$from" "$to" < /dev/tty; then
      echo "Warning: Failed to create symlink: $to" >&2
    fi
  fi
}

apply_dir() {
  dir="$1"
  exclude="${2:-}"
  find "$dir" -maxdepth 1 -mindepth 1 | while IFS= read -r item; do
    name="$(basename "$item")"
    case "$name" in
      ..|.) continue ;;
    esac
    if [ -n "$exclude" ]; then
      case "$name" in
        darwin|owner|assets) continue ;;
      esac
    fi
    create_symlink "$item" "$HOME/$name"
  done
}

main() {
  sync_repo

  echo 'Creating symlinks...'
  apply_dir "$dst/src" 'exclude'
  [ "$(uname)" = 'Darwin' ] && apply_dir "$dst/src/darwin"
  is_owner && apply_dir "$dst/src/owner"
}

main
