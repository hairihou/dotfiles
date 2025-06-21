#!/bin/zsh

set -eu

DOTFILES_DIR="${HOME}/dotfiles"
VSCODE_PROMPTS_DIR="${HOME}/Library/Application Support/Code/User/prompts"
SOURCE_DIR="${VSCODE_PROMPTS_DIR}/"
TARGET_DIR="${DOTFILES_DIR}/.github/instructions"

echo "Dumping VS Code prompt instructions: ${SOURCE_DIR} -> ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"
rsync -av --force "${SOURCE_DIR}" "${TARGET_DIR}/"
