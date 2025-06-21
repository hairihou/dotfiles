#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
VSCODE_PROMPTS_DIR="${HOME}/Library/Application Support/Code/User/prompts"
SOURCE_DIR="${DOTFILES_DIR}/.github/instructions/"

echo "Syncing VS Code prompt instructions: ${SOURCE_DIR} -> ${VSCODE_PROMPTS_DIR}"
mkdir -p "${VSCODE_PROMPTS_DIR}"
rsync -av --force "${SOURCE_DIR}" "${VSCODE_PROMPTS_DIR}/"
