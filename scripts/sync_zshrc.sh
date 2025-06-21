#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
TARGET_DIR="${HOME}"
SOURCE_FILE="${DOTFILES_DIR}/.zshrc"

echo "Syncing .zshrc: ${SOURCE_FILE} -> ${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
