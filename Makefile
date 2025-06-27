VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY: sync-gemini dump-gemini \
        sync-gitignore dump-gitignore \
        sync-mise dump-mise \
        sync-vscode-instructions dump-vscode-instructions \
        sync-vscode-settings dump-vscode-settings \
        sync-zshrc dump-zshrc \
        sync-all dump-all \
        brew-all \
        sync-gitconfig dump-gitconfig \
        user-defaults

sync-gemini:
	@rsync -av ./.gemini/GEMINI.md ./.gemini/settings.json "$(HOME)/.gemini/"

sync-gitignore:
	@rsync -av ./.config/git/ignore "$(HOME)/.config/git/"

sync-mise:
	@rsync -av ./.config/mise/ "$(HOME)/.config/mise/"

sync-vscode-instructions:
	@rsync -av ./.github/instructions/ "${VSCODE_USER_DIR}/prompts/"

sync-vscode-settings:
	@rsync -av ./.vscode/settings.json "${VSCODE_USER_DIR}/"

sync-zshrc:
	@rsync -av ./public/.zshrc "$(HOME)/"

sync-all: sync-gitignore sync-mise sync-vscode-instructions sync-vscode-settings sync-zshrc

dump-gemini:
	@rsync -av "$(HOME)/.gemini/GEMINI.md" "$(HOME)/.gemini/settings.json" ./.gemini/

dump-gitignore:
	@rsync -av "$(HOME)/.config/git/ignore" ./.config/git/

dump-mise:
	@rsync -av "$(HOME)/.config/mise/" ./.config/mise/

dump-vscode-instructions:
	@rsync -av "${VSCODE_USER_DIR}/prompts/" ./.github/instructions/

dump-vscode-settings:
	@rsync -av "${VSCODE_USER_DIR}/settings.json" ./.vscode/

dump-zshrc:
	@rsync -av "$(HOME)/.zshrc" ./public/

dump-all: dump-gitignore dump-mise dump-vscode-instructions dump-vscode-settings dump-zshrc

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
