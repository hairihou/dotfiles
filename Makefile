VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY:
	sync-claude dump-claude \
	sync-gitignore dump-gitignore \
	sync-mise dump-mise \
	sync-vscode-instructions dump-vscode-instructions \
	sync-vscode-mcp dump-vscode-mcp \
	sync-vscode-settings dump-vscode-settings \
	sync-vscode dump-vscode \
	sync-all dump-all \
	brew-all brew-stable \
	sync-gitconfig dump-gitconfig \
	defaults

sync-claude:
	@rsync -av --checksum ./src/.claude/commands/ "${HOME}/.claude/commands/"
	@rsync -av --checksum ./src/.claude/settings.json "${HOME}/.claude/"

sync-gitignore:
	@rsync -av --checksum ./src/.config/git/ignore "$(HOME)/.config/git/"

sync-mise:
	@rsync -av --checksum ./src/.config/mise/ "$(HOME)/.config/mise/"

sync-vscode-instructions:
	@rsync -av --checksum ./src/.github/instructions/ "${VSCODE_USER_DIR}/prompts/"

sync-vscode-mcp:
	@rsync -av --checksum ./src/.vscode/mcp.json "${VSCODE_USER_DIR}/"

sync-vscode-settings:
	@rsync -av --checksum ./src/.vscode/settings.json "${VSCODE_USER_DIR}/"

sync-vscode: sync-vscode-instructions sync-vscode-mcp sync-vscode-settings

sync-all: sync-claude sync-gitignore sync-mise sync-vscode

dump-claude:
	@rsync -av --checksum "${HOME}/.claude/commands/" ./src/.claude/commands/
	@rsync -av --checksum "${HOME}/.claude/settings.json" ./src/.claude/

dump-gitignore:
	@rsync -av --checksum "$(HOME)/.config/git/ignore" ./src/.config/git/

dump-mise:
	@rsync -av --checksum "$(HOME)/.config/mise/" ./src/.config/mise/

dump-vscode-instructions:
	@rsync -av --checksum "${VSCODE_USER_DIR}/prompts/" ./src/.github/instructions/

dump-vscode-mcp:
	@rsync -av --checksum "${VSCODE_USER_DIR}/mcp.json" ./src/.vscode/

dump-vscode-settings:
	@rsync -av --checksum "${VSCODE_USER_DIR}/settings.json" ./src/.vscode/

dump-vscode: dump-vscode-instructions dump-vscode-mcp dump-vscode-settings

dump-all: dump-claude dump-gitignore dump-mise dump-vscode

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
	@rsync -av --checksum ./src/.gitconfig "$(HOME)/"

dump-gitconfig:
	@rsync -av --checksum "$(HOME)/.gitconfig" ./src/

defaults:
	@sh ./scripts/defaults.sh
