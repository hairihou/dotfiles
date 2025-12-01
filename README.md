# dotfiles

> [!IMPORTANT]
> This dotfiles repository is designed for macOS only.

## Setup

```sh
curl -fsSL https://raw.githubusercontent.com/hairihou/dotfiles/main/install.sh | sh
```

## Overview

### Scripts (`/bin`)

Available globally after setup:

- `brewsync [--dump | --prune]` - Homebrew package synchronizer
- `brewup [--all]` - Homebrew batch update utility
- `cdefaults` - macOS system defaults configuration
- `codext [--dump | --prune]` - VS Code extension manager
- `dprune` - Remove empty directories from repository
- `tresize [s|m|l|xl]` - Terminal window resizer

### Configuration Files (`/src`)

Symlinked to home directory:

| Source                             | Target                                                  |
| ---------------------------------- | ------------------------------------------------------- |
| `src/.claude/commands`             | `~/.claude/commands`<br>`~/.codex/prompts`              |
| `src/.claude/skills`               | `~/.codex/skills`                                       |
| `src/.claude/CLAUDE.md`            | `~/.claude/CLAUDE.md`<br>`~/.codex/AGENTS.md`           |
| `src/.claude/settings.json`        | `~/.claude/settings.json`                               |
| `src/.config/brew/.Brewfile`       | `~/.Brewfile`                                           |
| `src/.config/brew/.Brewfile.owner` | `~/.Brewfile` (owner only)                              |
| `src/.config/git/ignore`           | `~/.config/git/ignore`                                  |
| `src/.config/mise/config.toml`     | `~/.config/mise/config.toml`                            |
| `src/.config/zellij/config.kdl`    | `~/.config/zellij/config.kdl`                           |
| `src/.gitconfig`                   | `~/.gitconfig` (owner only)                             |
| `src/.github/instructions`         | `~/Library/Application Support/Code/User/prompts`       |
| `src/.vscode/settings.json`        | `~/Library/Application Support/Code/User/settings.json` |
| `src/.zshrc`                       | `~/.zshrc`                                              |
