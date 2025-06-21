#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
SOURCE_FILE="${HOME}/.gitconfig"
TARGET_DIR="${DOTFILES_DIR}/.config"

echo "Dumping gitconfig: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
