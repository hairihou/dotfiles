# dotfiles

## Setup

> [!IMPORTANT]
> This dotfiles repository is designed for macOS only.

```sh
curl -fsSL https://raw.githubusercontent.com/hairihou/dotfiles/main/install.sh | sh
```

## Overview

### Scripts (`/bin`)

Available globally after setup:

- `brewup [-b --include-beta]` - Homebrew batch update utility
- `cdefaults` - macOS system defaults configuration
- `codext [--dump | --prune]` - VS Code extension manager
- `dprune` - Remove empty directories from repository
- `tresize [s|m|l|xl]` - Terminal window resizer

### Configuration Files (`/src`)

Symlinked to home directory:

| Source                             | Target                                                  |
| ---------------------------------- | ------------------------------------------------------- |
| `src/.claude/commands`             | `~/.claude/commands`<br>`~/.codex/prompts`              |
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

## Customization

### Managing Homebrew Packages

Brewfile is located at `~/dotfiles/src/.config/brew/.Brewfile` and symlinked to `~/.Brewfile`.

```sh
# Install packages from Brewfile
brew bundle --global --no-vscode

# Add currently installed packages to Brewfile
brew bundle dump --global --no-vscode

# List packages not in Brewfile
brew bundle cleanup --global --no-vscode

# Remove packages not in Brewfile
brew bundle cleanup --force --global --no-vscode
```

<!-- https://user-images.githubusercontent.com/38448411/120893176-d64b3800-c64c-11eb-827e-2d0f96f3088b.jpeg -->
<!-- T8pcHI1j -->
