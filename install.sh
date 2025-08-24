#!/bin/bash
set -euo pipefail

readonly dest="$HOME/dotfiles"
readonly repo='https://github.com/hairihou/dotfiles.git'

if [ ! -e "$dest/.git" ]; then
  git clone "$repo" "$dest"
else
  echo "Updating existing repository..."
  cd "$dest"
  git fetch --prune
  git switch main
  git pull origin main
fi

if [ "$(uname)" == 'Darwin' ]; then
  ln -si "$dest/src/.zshrc" "$HOME/.zshrc" || echo "Symlink creation skipped."
else
  echo "($(uname -a)) is not supported."
  exit 1
fi
