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

| Source                    | Target                         |
| ------------------------- | ------------------------------ |
| `src/.Brewfile`           | `~/.Brewfile`                  |
| `src/.claude/**/*`        | `~/.claude/**/*`               |
| `src/.codex/**/*`         | `~/.codex/**/*`                |
| `src/.config/**/*`        | `~/.config/**/*`               |
| `src/.zshrc`              | `~/.zshrc`                     |
| `src/darwin/Library/**/*` | `~/Library/**/*` (Darwin only) |
| `src/owner/.Brewfile`     | `~/.Brewfile` (owner only)     |
| `src/owner/.gitconfig`    | `~/.gitconfig` (owner only)    |
