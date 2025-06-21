#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
SOURCE_FILE="${HOME}/.zshrc"
TARGET_DIR="${DOTFILES_DIR}"

echo "Dumping .zshrc: ${SOURCE_FILE} -> ${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
