#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
CONFIG_DIR="${HOME}/.config"
TARGET_DIR="${CONFIG_DIR}/mise"
SOURCE_FILE="${DOTFILES_DIR}/.config/mise/config.toml"

echo "Syncing mise config: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
