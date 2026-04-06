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
- `dprune` - Remove `.DS_Store` and empty directories from git repository
- `linkup [--dry-run]` - Symlink manager (re-apply or preview changes)
- `xdgclean [--dry-run]` - Remove broken symlinks and empty directories from XDG base directories

### Configuration Files (`/src`)

Symlinked to home directory:

| Source                 | Target                      |
| ---------------------- | --------------------------- |
| `src/.config/**/*`     | `~/.config/**/*`            |
| `src/.Brewfile`        | `~/.Brewfile`               |
| `src/.npmrc`           | `~/.npmrc`                  |
| `src/.zshrc`           | `~/.zshrc`                  |
| `src/.Brewfile.owner`  | `~/.Brewfile` (owner only)  |
| `src/.gitconfig.owner` | `~/.gitconfig` (owner only) |

## Machine-Local Configuration

`~/.zshrc.local` is sourced at the end of `.zshrc` for machine-specific environment variables. This file is not managed by this repository.
