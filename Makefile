# Makefile for managing dotfiles and system configurations
# Assumes execution on macOS with zsh. Individual scripts use zsh via shebang.

SCRIPTS_DIR := ./scripts

# Colors for help message
GREEN := $(shell tput setaf 2)
RESET := $(shell tput sgr0)

.PHONY: help \
        sync-zshrc dump-zshrc \
        sync-gitconfig dump-gitconfig \
        sync-gitignore dump-gitignore \
        sync-mise dump-mise \
        sync-vscode-settings dump-vscode-settings \
        sync-vscode-instructions dump-vscode-instructions \
        sync-all dump-all \
        brew-all \
        user-defaults

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  ${GREEN}help${RESET}                       Show this help message"
	@echo ""
	@echo "  --- Sync Dotfiles (Dotfiles -> System) ---"
	@echo "  ${GREEN}sync-zshrc${RESET}               Sync .zshrc"
	@echo "  ${GREEN}sync-gitconfig${RESET}           Sync gitconfig"
	@echo "  ${GREEN}sync-gitignore${RESET}           Sync git ignore"
	@echo "  ${GREEN}sync-mise${RESET}                Sync mise config"
	@echo "  ${GREEN}sync-vscode-settings${RESET}     Sync VS Code settings"
	@echo "  ${GREEN}sync-vscode-instructions${RESET} Sync VS Code prompt instructions"
	@echo "  ${GREEN}sync-all${RESET}                 Sync all above dotfiles"
	@echo ""
	@echo "  --- Dump Configs (System -> Dotfiles) ---"
	@echo "  ${GREEN}dump-zshrc${RESET}               Dump .zshrc"
	@echo "  ${GREEN}dump-gitconfig${RESET}           Dump gitconfig"
	@echo "  ${GREEN}dump-gitignore${RESET}           Dump git ignore"
	@echo "  ${GREEN}dump-mise${RESET}                Dump mise config"
	@echo "  ${GREEN}dump-vscode-settings${RESET}     Dump VS Code settings"
	@echo "  ${GREEN}dump-vscode-instructions${RESET} Dump VS Code prompt instructions"
	@echo "  ${GREEN}dump-all${RESET}                 Dump all above configs"
	@echo ""
	@echo "  --- Homebrew ---"
	@echo "  ${GREEN}brew-all${RESET}                 Update, upgrade, and clean Homebrew"
	@echo ""
	@echo "  --- macOS ---"
	@echo "  ${GREEN}user-defaults${RESET}            Configure macOS Dock settings"


# Default target
default: help

# Sync Dotfiles
sync-zshrc:
	@zsh ${SCRIPTS_DIR}/sync_zshrc.sh

sync-gitconfig:
	@zsh ${SCRIPTS_DIR}/sync_gitconfig.sh

sync-gitignore:
	@zsh ${SCRIPTS_DIR}/sync_gitignore.sh

sync-mise:
	@zsh ${SCRIPTS_DIR}/sync_mise.sh

sync-vscode-settings:
	@zsh ${SCRIPTS_DIR}/sync_vscode_settings.sh

sync-vscode-instructions:
	@zsh ${SCRIPTS_DIR}/sync_vscode_instructions.sh

sync-all: sync-zshrc sync-gitconfig sync-gitignore sync-mise sync-vscode-settings sync-vscode-instructions
	@echo "All dotfiles synced successfully"

# Dump Configs
dump-zshrc:
	@zsh ${SCRIPTS_DIR}/dump_zshrc.sh

dump-gitconfig:
	@zsh ${SCRIPTS_DIR}/dump_gitconfig.sh

dump-gitignore:
	@zsh ${SCRIPTS_DIR}/dump_gitignore.sh

dump-mise:
	@zsh ${SCRIPTS_DIR}/dump_mise.sh

dump-vscode-settings:
	@zsh ${SCRIPTS_DIR}/dump_vscode_settings.sh

dump-vscode-instructions:
	@zsh ${SCRIPTS_DIR}/dump_vscode_instructions.sh

dump-all: dump-zshrc dump-gitconfig dump-gitignore dump-mise dump-vscode-settings dump-vscode-instructions
	@echo "All configs dumped successfully"

# Homebrew
brew-all:
	@zsh ${SCRIPTS_DIR}/brew_all.sh

# macOS
user-defaults:
	@zsh ${SCRIPTS_DIR}/user_defaults.sh
