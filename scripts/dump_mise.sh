#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
SOURCE_FILE="${CONFIG_DIR}/mise/config.toml"
TARGET_DIR="${DOTFILES_DIR}/.config/mise"

echo "Dumping mise config: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
