#!/usr/bin/env bash
set -euo pipefail

readonly DST="$HOME/dotfiles"
readonly SRC='https://github.com/hairihou/dotfiles.git'

if [ ! -e "$DST/.git" ]; then
  git clone "$SRC" "$DST"
elif [ "$(git -C "$DST" config --get remote.origin.url)" != "$SRC" ]; then
  echo 'Error: Remote origin URL does not match expected URL'
  exit 1
else
  echo 'Updating existing repository...'
  git -C "$DST" fetch --prune
  git -C "$DST" switch main
  git -C "$DST" pull origin main
fi

"$DST/bin/linkup"
