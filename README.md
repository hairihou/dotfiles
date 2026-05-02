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
- `dprune` - Remove `.DS_Store` files and empty directories
- `linkup [--dry-run]` - Symlink manager (re-apply or preview changes)
- `macos-defaults` - macOS system defaults configuration
- `xdgclean [--dry-run]` - Remove broken symlinks and empty directories from XDG base directories

### Configuration Files (`/src`)

Files are symlinked into `$HOME`. Edit them in `src/` — `$HOME` targets are overwritten by `linkup`.

| Source                 | Target                      |
| ---------------------- | --------------------------- |
| `src/.claude/**/*`     | `~/.claude/**/*`            |
| `src/.config/**/*`     | `~/.config/**/*`            |
| `src/.Brewfile`        | `~/.Brewfile`               |
| `src/.npmrc`           | `~/.npmrc`                  |
| `src/.zshrc`           | `~/.zshrc`                  |
| `src/.Brewfile.owner`  | `~/.Brewfile` (owner only)  |
| `src/.gitconfig.owner` | `~/.gitconfig` (owner only) |

## Philosophy

Principles guiding tool selection and environment management in this repository:

- **Detect, don't assume** — detect host environment at runtime, never hardcode a product
- **Explicit over implicit** — modify shared global state via deliberate commands, not in-place edits
- **Isolation by default** — run third-party packages in ephemeral environments
- **Registry first, upstream as source of truth** — curated registry for tools it covers, otherwise direct upstream

## Machine-Local Configuration

`~/.zshrc.local` is sourced at the end of `.zshrc` for machine-specific environment variables. This file is not managed by this repository.
