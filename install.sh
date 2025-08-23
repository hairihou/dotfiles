#!/bin/bash
set -euo pipefail

dest="$HOME/dotfiles"
repo='https://github.com/hairihou/dotfiles.git'

if [ ! -e $dest/.git ]; then
  git clone $repo $dest
else
  cd $dest
  git fetch --prune
  git switch main
  git pull origin main
fi

if [ "$(uname)" == 'Darwin' ]; then
  make -C $dest sync-gitignore
  make -C $dest sync-vscode-settings
  make -C $dest sync-zshrc
else
  echo "($(uname -a)) is not supported."
  exit 1
fi
