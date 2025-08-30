VSCODE_USER_DIR := $(HOME)/Library/Application Support/Code/User

.PHONY:
	brew-all brew-stable \
	dump-all dump-claude dump-github-instructions dump-mise \
	sync-all sync-claude sync-github-instructions sync-mise

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

dump-all: dump-claude dump-github-instructions dump-mise

dump-claude:
	@rsync -av --checksum "${HOME}/.claude/commands/" ./src/.claude/commands/
	@rsync -av --checksum "${HOME}/.claude/CLAUDE.md" ./src/.claude/
	@rsync -av --checksum "${HOME}/.claude/settings.json" ./src/.claude/

dump-github-instructions:
	@rsync -av --checksum "${VSCODE_USER_DIR}/prompts/" ./src/.github/instructions/

dump-mise:
	@rsync -av --checksum "$(HOME)/.config/mise/" ./src/.config/mise/

sync-all: sync-claude sync-github-instructions sync-mise

sync-claude:
	@rsync -av --checksum ./src/.claude/commands/ "${HOME}/.claude/commands/"
	@rsync -av --checksum ./src/.claude/CLAUDE.md "${HOME}/.claude/"
	@rsync -av --checksum ./src/.claude/settings.json "${HOME}/.claude/"
	@mkdir -p "${HOME}/.codex"
	@rm -rf "${HOME}/.codex/AGENTS.md"
	@ln -s "${HOME}/.claude/CLAUDE.md" "${HOME}/.codex/AGENTS.md"

sync-github-instructions:
	@rsync -av --checksum ./src/.github/instructions/ "${VSCODE_USER_DIR}/prompts/"

sync-mise:
	@rsync -av --checksum ./src/.config/mise/ "$(HOME)/.config/mise/"
