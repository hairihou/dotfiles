#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
SOURCE_FILE="${VSCODE_USER_DIR}/settings.json"
TARGET_DIR="${DOTFILES_DIR}/.vscode/global"

echo "Dumping VS Code settings: ${SOURCE_FILE} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_FILE}" "${TARGET_DIR}/"
