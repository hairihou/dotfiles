DOTFILES_DIR := $(HOME)/dotfiles
VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY: sync-zshrc dump-zshrc \
        sync-gitignore dump-gitignore \
        sync-mise dump-mise \
        sync-vscode-settings dump-vscode-settings \
        sync-vscode-instructions dump-vscode-instructions \
        sync-all dump-all \
				brew-all \
        sync-gitconfig dump-gitconfig \
        user-defaults

sync-zshrc:
	@rsync -av "$(DOTFILES_DIR)/public/.zshrc" "$(HOME)/"

sync-gitignore:
	@rsync -av "$(DOTFILES_DIR)/.config/git/ignore" "$(HOME)/.config/git/"

sync-mise:
	@rsync -av "$(DOTFILES_DIR)/.config/mise/" "$(HOME)/.config/mise/"

sync-vscode-settings:
	@rsync -av "$(DOTFILES_DIR)/.vscode/settings.json" "${VSCODE_USER_DIR}/"

sync-vscode-instructions:
	@rsync -av "$(DOTFILES_DIR)/.github/instructions/" "${VSCODE_USER_DIR}/prompts/"

sync-all: sync-zshrc sync-gitignore sync-mise sync-vscode-settings sync-vscode-instructions

dump-zshrc:
	@rsync -av "$(HOME)/.zshrc" "$(DOTFILES_DIR)/public/"

dump-gitignore:
	@rsync -av "$(HOME)/.config/git/ignore" "$(DOTFILES_DIR)/.config/git/"

dump-mise:
	@rsync -av "$(HOME)/.config/mise/" "$(DOTFILES_DIR)/.config/mise/"

dump-vscode-settings:
	@rsync -av "${VSCODE_USER_DIR}/settings.json" "$(HOME)/dotfiles/.vscode/"

dump-vscode-instructions:
	@rsync -av "${VSCODE_USER_DIR}/prompts/" "$(DOTFILES_DIR)/.github/instructions/"

dump-all: dump-zshrc dump-gitignore dump-mise dump-vscode-settings dump-vscode-instructions

brew-all:
	@brew update
	@brew upgrade --formula $(brew ls --formula)
	@brew upgrade --cask $(brew ls --cask)
	@brew cleanup --prune=all --scrub

sync-gitconfig:
	@rsync -av "$(DOTFILES_DIR)/public/.gitconfig" "$(HOME)/"

dump-gitconfig:
	@rsync -av "$(HOME)/.gitconfig" "$(DOTFILES_DIR)/public/"

user-defaults:
	@zsh "$(DOTFILES_DIR)/scripts/user-defaults.sh"
