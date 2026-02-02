# dotfiles

> [!IMPORTANT]
> This dotfiles repository is designed for macOS only.

## Setup

```sh
curl -fsSL https://raw.githubusercontent.com/hairihou/dotfiles/main/install.sh | bash
```

## Overview

### Scripts (`/bin`)

Available globally after setup:

- `brewsync [--dump | --prune]` - Homebrew package synchronizer
- `brewup [--all]` - Homebrew batch update utility
- `cdefaults` - macOS system defaults configuration
- `codext [--dump | --prune]` - VS Code extension manager
- `dprune` - Remove empty directories from repository

### Configuration Files (`/src`)

Symlinked to home directory:

| Source                     | Target                         |
| -------------------------- | ------------------------------ |
| `src/.Brewfile`            | `~/.Brewfile`                  |
| `src/.claude/**/*`         | `~/.claude/**/*`               |
| `src/.codex/**/*`          | `~/.codex/**/*`                |
| `src/.config/**/*`         | `~/.config/**/*`               |
| `src/.zshrc`               | `~/.zshrc`                     |
| `src/_darwin/Library/**/*` | `~/Library/**/*` (Darwin only) |
| `src/.Brewfile.owner`      | `~/.Brewfile` (owner only)     |
| `src/.gitconfig.owner`     | `~/.gitconfig` (owner only)    |
