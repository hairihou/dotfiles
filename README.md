# dotfiles

> [!IMPORTANT]
> This dotfiles repository is designed for macOS only.

## Setup

Install [mise](https://mise.jdx.dev) first:

```sh
curl https://mise.run | sh
```

Then run the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/hairihou/dotfiles/main/install.sh | bash
```

## Overview

### Scripts (`/bin`)

Available globally after setup:

- `brewsync [--dump | --prune]` - Homebrew package synchronizer
- `brewup [--all]` - Homebrew batch update utility
- `dprune` - Remove `.DS_Store` files and empty directories
- `xdgclean [--dry-run]` - Remove broken symlinks (`$HOME` top level, XDG base directories, `~/.claude`) and empty directories (XDG base directories, `~/.claude`)
- `zhistprune` - Remove `.zsh_history` entries older than 90 days

### Owner / Work

`install.sh` symlinks the Brewfile and gitconfig per machine, chosen by git email: owner machines get the `.owner` variants, work machines get the base files. The base `.gitconfig` reads the git identity (`[user]`) from `~/.gitconfig.local`; `.gitconfig.owner` includes the base and bakes in the owner identity.

### Syncing

Re-apply after editing `src/` (or re-run `install.sh`):

```sh
mise bootstrap macos-defaults apply    # write macOS defaults (log out to fully apply)
mise dotfiles apply                    # re-create symlinks
mise dotfiles status                   # show drift between src/ and $HOME
```

## Philosophy

Principles guiding tool selection and environment management in this repository:

- **Detect, don't assume** — detect host environment at runtime, never hardcode a product
- **Explicit over implicit** — modify shared global state via deliberate commands, not in-place edits
- **Isolation by default** — run third-party packages in ephemeral environments
- **Registry first, upstream as source of truth** — curated registry for tools it covers, otherwise direct upstream

## Machine-Local Configuration

Machine-specific values live in `*.local` files, which are git-ignored. Keep them in `src/`; `install.sh` symlinks each present `src/*.local` into `$HOME`, and the content is never committed.

- `~/.zshrc.local` — sourced at the end of `.zshrc` for environment variables
- `~/.gitconfig.local` — included by `.gitconfig` to provide the git identity (`[user]`)
