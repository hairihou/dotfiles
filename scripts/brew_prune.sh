#!/bin/zsh

set -eu

echo "Cleaning up Homebrew"
brew cleanup --prune=all --scrub
