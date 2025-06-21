#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
TARGET_DIR="${HOME}"
SOURCE_FILE="${DOTFILES_DIR}/.config/.gitconfig"

echo "Syncing gitconfig: ${SOURCE_FILE} -> ${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
