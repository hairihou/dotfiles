#!/usr/bin/env bash
set -euo pipefail

readonly dst="$HOME/dotfiles"
readonly src='https://github.com/hairihou/dotfiles.git'
readonly symlinks_record="$dst/dist/.symlinks"

is_owner() {
  [ "$(whoami)" = 'hairihou' ]
}

resolve_symlink() {
  local link="$1"
  local target
  target="$(readlink "$link")"
  case "$target" in
    /*)
      echo "$target"
      ;;
    *)
      local dir
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
  local from="$1"
  local to="$2"
  local parent
  parent="$(dirname "$to")"

  if [ -L "$to" ] && [ "$(resolve_symlink "$to")" = "$from" ]; then
    record_symlink "$to"
    return 0
  fi

  # Prevent circular symlinks
  if [ -L "$parent" ]; then
    local parent_target
    parent_target="$(resolve_symlink "$parent")"
    case "$parent_target" in
      "$dst/src"*) return 0 ;;
    esac
  fi

  if [ "$parent" != "$HOME" ] && [ ! -d "$parent" ]; then
    mkdir -p "$parent"
  fi

  if [ -d "$from" ]; then
    if [ -d "$to" ]; then
      cleanup_broken_symlinks_in "$to"
    elif [ -e "$to" ]; then
      echo "Warning: Cannot create directory '$to': file exists. Skipping." >&2
      return 0
    else
      mkdir -p "$to"
    fi
    local file
    find "$from" -maxdepth 1 -mindepth 1 | while IFS= read -r file; do
      create_symlink "$file" "$to/$(basename "$file")"
    done
  elif [ -f "$from" ]; then
    if ln -sfi "$from" "$to" < /dev/tty; then
      record_symlink "$to"
    else
      echo "Warning: Failed to create symlink: $to" >&2
    fi
  fi
}

apply_dir() {
  local dir="$1"
  local exclude="${2:-}"
  local item name
  find "$dir" -maxdepth 1 -mindepth 1 | while IFS= read -r item; do
    name="$(basename "$item")"
    if [ -n "$exclude" ]; then
      case "$name" in
        _*|*.owner) continue ;;
      esac
    fi
    create_symlink "$item" "$HOME/$name"
  done
}

cleanup_broken_symlinks_in() {
  local dir="$1"
  local link target
  while IFS= read -r link; do
    target="$(resolve_symlink "$link")"
    case "$target" in
      "$dst/src"*)
        if [ ! -e "$target" ]; then
          echo "Removing broken symlink: $link"
          rm "$link"
        fi
        ;;
    esac
  done < <(find "$dir" -maxdepth 1 -type l 2>/dev/null)
}

cleanup_recorded_symlinks() {
  [ -f "$symlinks_record" ] || return 0
  local link
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    if [ -L "$link" ] && [ ! -e "$link" ]; then
      echo "Removing broken symlink: $link"
      rm "$link"
    fi
  done < "$symlinks_record"
}

record_symlink() {
  echo "$1" >> "$symlinks_record.new"
}

main() {
  sync_repo

  echo 'Cleaning up broken symlinks...'
  cleanup_recorded_symlinks

  echo 'Creating symlinks...'
  mkdir -p "$(dirname "$symlinks_record")"
  : > "$symlinks_record.new"
  cleanup_broken_symlinks_in "$HOME"
  apply_dir "$dst/src" 'exclude'
  [ "$(uname)" = 'Darwin' ] && apply_dir "$dst/src/_darwin"
  if is_owner; then
    create_symlink "$dst/src/.Brewfile.owner" "$HOME/.Brewfile"
    create_symlink "$dst/src/.gitconfig.owner" "$HOME/.gitconfig"
  fi
  sort -u "$symlinks_record.new" -o "$symlinks_record"
  rm -f "$symlinks_record.new"
}

main
