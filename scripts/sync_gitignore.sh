#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
TARGET_DIR="${CONFIG_DIR}/git"
SOURCE_FILE="${DOTFILES_DIR}/.config/git/ignore"

echo "Syncing git ignore: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
