#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
VSCODE_PROMPTS_DIR="${HOME}/Library/Application Support/Code/User/prompts" # src/tasks.ts の Paths.Vscode とは異なる点に注意
SOURCE_DIR="${DOTFILES_DIR}/.github/instructions/"

echo "Syncing VS Code prompt instructions: ${SOURCE_DIR} -> ${VSCODE_PROMPTS_DIR}"
mkdir -p "${VSCODE_PROMPTS_DIR}"
rsync -av --force "${SOURCE_DIR}" "${VSCODE_PROMPTS_DIR}/"
