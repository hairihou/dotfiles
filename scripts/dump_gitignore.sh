#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
SOURCE_FILE="${CONFIG_DIR}/git/ignore"
TARGET_DIR="${DOTFILES_DIR}/.config/git"

echo "Dumping git ignore: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
