VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY:
	sync-claude dump-claude \
	sync-gitignore dump-gitignore \
	sync-mise dump-mise \
	sync-vscode-instructions dump-vscode-instructions \
	sync-vscode-mcp dump-vscode-mcp \
	sync-vscode-settings dump-vscode-settings \
	sync-vscode dump-vscode \
	sync-zshrc dump-zshrc \
	sync-all dump-all \
	brew-all brew-stable \
	sync-gitconfig dump-gitconfig \
	defaults

sync-claude:
	@rsync -av --checksum ./.claude/commands/ "${HOME}/.claude/commands/"
	@rsync -av --checksum ./.claude/settings.json "${HOME}/.claude/"

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

sync-vscode: sync-vscode-instructions sync-vscode-mcp sync-vscode-settings

sync-zshrc:
	@rsync -av --checksum ./public/.zshrc "$(HOME)/"

sync-all: sync-claude sync-gitignore sync-mise sync-vscode sync-zshrc

dump-claude:
	@rsync -av --checksum "${HOME}/.claude/commands/" ./.claude/commands/
	@rsync -av --checksum "${HOME}/.claude/settings.json" ./.claude/

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

dump-vscode: dump-vscode-instructions dump-vscode-mcp dump-vscode-settings

dump-zshrc:
	@rsync -av --checksum "$(HOME)/.zshrc" ./public/

dump-all: dump-claude dump-gitignore dump-mise dump-vscode dump-zshrc

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

defaults:
	@sh ./scripts/defaults.sh
