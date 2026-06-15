#!/usr/bin/env bash
set -euo pipefail

readonly DST="$HOME/dotfiles"
readonly SRC='https://github.com/hairihou/dotfiles.git'

export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise > /dev/null 2>&1; then
  echo 'mise is required. Install it first (see README), then re-run.' >&2
  exit 1
fi

if [[ ! -e "$DST/.git" ]]; then
  git clone "$SRC" "$DST"
elif [[ "$(git -C "$DST" config --get remote.origin.url)" != "$SRC" ]]; then
  echo 'Error: Remote origin URL does not match expected URL'
  exit 1
else
  echo 'Updating existing repository...'
  git -C "$DST" fetch --prune
  git -C "$DST" switch main
  git -C "$DST" pull origin main
fi

is_owner() {
  local email
  email="$(git config --global user.email)"
  [[ $email == hairihou@* || $email == *+hairihou@users.noreply.github.com ]]
}

mkdir -p "$HOME/.config/mise"
ln -sf "$DST/src/.config/mise/config.toml" "$HOME/.config/mise/config.toml"
mise dotfiles apply --force --yes

if is_owner; then
  ln -sf "$DST/src/.Brewfile.owner" "$HOME/.Brewfile"
  ln -sf "$DST/src/.gitconfig.owner" "$HOME/.gitconfig"
else
  ln -sf "$DST/src/.Brewfile" "$HOME/.Brewfile"
  ln -sf "$DST/src/.gitconfig" "$HOME/.gitconfig"
fi

for local_file in "$DST"/src/.*.local; do
  if [[ -e "$local_file" ]]; then
    ln -sf "$local_file" "$HOME/$(basename "$local_file")"
  fi
done
