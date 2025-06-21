#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"
SOURCE_FILE="${DOTFILES_DIR}/.vscode/global/settings.json"

echo "Syncing VS Code settings: ${SOURCE_FILE} -> ${VSCODE_USER_DIR}"
rsync -av --force "${SOURCE_FILE}" "${VSCODE_USER_DIR}/"
