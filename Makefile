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
	@rsync -av ./public/.zshrc "$(HOME)/"

sync-gitignore:
	@rsync -av ./.config/git/ignore "$(HOME)/.config/git/"

sync-mise:
	@rsync -av ./.config/mise/ "$(HOME)/.config/mise/"

sync-vscode-settings:
	@rsync -av ./.vscode/settings.json "${VSCODE_USER_DIR}/"

sync-vscode-instructions:
	@rsync -av ./.github/instructions/ "${VSCODE_USER_DIR}/prompts/"

sync-all: sync-zshrc sync-gitignore sync-mise sync-vscode-settings sync-vscode-instructions

dump-zshrc:
	@rsync -av "$(HOME)/.zshrc" ./public/

dump-gitignore:
	@rsync -av "$(HOME)/.config/git/ignore" ./.config/git/

dump-mise:
	@rsync -av "$(HOME)/.config/mise/" ./.config/mise/

dump-vscode-settings:
	@rsync -av "${VSCODE_USER_DIR}/settings.json" ./.vscode/

dump-vscode-instructions:
	@rsync -av "${VSCODE_USER_DIR}/prompts/" ./.github/instructions/

dump-all: dump-zshrc dump-gitignore dump-mise dump-vscode-settings dump-vscode-instructions

brew-all:
	@brew update
	@brew upgrade --formula $$(brew ls --formula)
	@brew upgrade --cask $$(brew ls --cask)
	@brew cleanup --prune=all --scrub
	@brew autoremove

sync-gitconfig:
	@rsync -av ./public/.gitconfig "$(HOME)/"

dump-gitconfig:
	@rsync -av "$(HOME)/.gitconfig" ./public/

user-defaults:
	@zsh ./scripts/user-defaults.sh
