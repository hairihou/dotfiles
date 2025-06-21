# dotfiles

My dotfiles.

## Usage

This repository uses a Makefile to manage dotfiles and system configurations.

### Available Commands

You can see the list of available commands by running:

```bash
make help
```

or simply:

```bash
make
```

This will display a help message with all available targets.

### Common Tasks

- **Sync all dotfiles to your system:**
  ```bash
  make sync-all
  ```
- **Dump all system configurations to this repository:**
  ```bash
  make dump-all
  ```
- **Update, upgrade, and clean Homebrew:**
  ```bash
  make brew-all
  ```
- **Apply macOS Dock settings:**
  ```bash
  make user-defaults
  ```

Refer to the `make help` output for a complete list of individual sync/dump tasks and other utilities.
