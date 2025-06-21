DOTFILES_DIR := "${HOME}/dotfiles"
VSCODE_USER_DIR := "${HOME}/Library/Application\ Support/Code/User"

.PHONY: sync-zshrc dump-zshrc \
        sync-gitignore dump-gitignore \
        sync-mise dump-mise \
        sync-vscode-settings dump-vscode-settings \
        sync-vscode-instructions dump-vscode-instructions \
        sync-all dump-all \
				sync-gitconfig dump-gitconfig \
        user-defaults

sync-zshrc:
	@rsync -av --force "${DOTFILES_DIR}/.zshrc" "${HOME}/"

sync-gitignore:
	@rsync -av --force "${DOTFILES_DIR}/.config/git/ignore" "${HOME}/.config/git/"

sync-mise:
	@rsync -av --force "${DOTFILES_DIR}/.config/mise/" "${HOME}/.config/mise/"

sync-vscode-settings:
	@rsync -av --force "${DOTFILES_DIR}/.vscode/global/settings.json" "${VSCODE_USER_DIR}/"

sync-vscode-instructions:
	@rsync -av --force "${DOTFILES_DIR}/.github/instructions/" "${VSCODE_USER_DIR}/prompts/"

sync-all: sync-zshrc sync-gitignore sync-mise sync-vscode-settings sync-vscode-instructions

dump-zshrc:
	@rsync -av --force "${HOME}/.zshrc" "${DOTFILES_DIR}/"

dump-gitignore:
	@rsync -av --force "${HOME}/.config/git/ignore" "${DOTFILES_DIR}/.config/git/"

dump-mise:
	@rsync -av --force "${HOME}/.config/mise/" "${DOTFILES_DIR}/.config/mise/"

dump-vscode-settings:
	@rsync -av --force "${VSCODE_USER_DIR}/settings.json" "${HOME}/dotfiles/.vscode/global/"

dump-vscode-instructions:
	@rsync -av --force "${VSCODE_USER_DIR}/prompts/" "${DOTFILES_DIR}/.github/instructions/"

dump-all: dump-zshrc dump-gitignore dump-mise dump-vscode-settings dump-vscode-instructions

sync-gitconfig:
	@rsync -av --force "${DOTFILES_DIR}/.config/.gitconfig" "${HOME}/"

dump-gitconfig:
	@rsync -av --force "${HOME}/.gitconfig" "${DOTFILES_DIR}/.config/"

user-defaults:
	@zsh "${DOTFILES_DIR}/scripts/user-defaults.sh"
