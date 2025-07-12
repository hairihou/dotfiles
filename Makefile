VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY: sync-gemini dump-gemini \
        sync-gitignore dump-gitignore \
        sync-mise dump-mise \
        sync-vscode-instructions dump-vscode-instructions \
        sync-vscode-mcp dump-vscode-mcp \
        sync-vscode-settings dump-vscode-settings \
        sync-zshrc dump-zshrc \
        sync-all dump-all \
        brew-all brew-stable \
        sync-gitconfig dump-gitconfig \
        user-defaults

sync-gemini:
	@rsync -av --checksum ./.gemini/GEMINI.md ./.gemini/settings.json "$(HOME)/.gemini/"

sync-gitignore:
	@rsync -av --checksum ./.config/git/ignore "$(HOME)/.config/git/"

sync-mise:
	@rsync -av --checksum ./.config/mise/ "$(HOME)/.config/mise/"

sync-vscode-instructions:
	@rsync -av --checksum ./.github/instructions/ "${VSCODE_USER_DIR}/prompts/"

sync-vscode-mcp:
	@rsync -av --checksum ./.vscode/mcp.json "${VSCODE_USER_DIR}/"

sync-vscode-settings:
	@rsync -av --checksum ./.vscode/settings.json "${VSCODE_USER_DIR}/"

sync-zshrc:
	@rsync -av --checksum ./public/.zshrc "$(HOME)/"

sync-all: sync-gemini sync-gitignore sync-mise sync-vscode-instructions sync-vscode-settings sync-zshrc

dump-gemini:
	@rsync -av --checksum "$(HOME)/.gemini/GEMINI.md" "$(HOME)/.gemini/settings.json" ./.gemini/

dump-gitignore:
	@rsync -av --checksum "$(HOME)/.config/git/ignore" ./.config/git/

dump-mise:
	@rsync -av --checksum "$(HOME)/.config/mise/" ./.config/mise/

dump-vscode-instructions:
	@rsync -av --checksum "${VSCODE_USER_DIR}/prompts/" ./.github/instructions/

dump-vscode-mcp:
	@rsync -av --checksum "${VSCODE_USER_DIR}/mcp.json" ./.vscode/

dump-vscode-settings:
	@rsync -av --checksum "${VSCODE_USER_DIR}/settings.json" ./.vscode/

dump-zshrc:
	@rsync -av --checksum "$(HOME)/.zshrc" ./public/

dump-all: dump-gemini dump-gitignore dump-mise dump-vscode-instructions dump-vscode-settings dump-zshrc

brew-all:
	@brew update
	@brew upgrade --formula $$(brew ls --formula)
	@brew upgrade --cask $$(brew ls --cask)
	@brew cleanup --prune=all --scrub
	@brew autoremove

brew-stable:
	@brew update
	@brew upgrade --formula $$(brew ls --formula)
	@brew upgrade --cask $$(brew ls --cask | grep -v '@')
	@brew cleanup --prune=all --scrub
	@brew autoremove

sync-gitconfig:
	@rsync -av --checksum ./public/.gitconfig "$(HOME)/"

dump-gitconfig:
	@rsync -av --checksum "$(HOME)/.gitconfig" ./public/

user-defaults:
	@zsh ./scripts/user-defaults.sh
