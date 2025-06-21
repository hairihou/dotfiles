#!/bin/zsh

set -eu

echo "--- Starting Homebrew Maintenance ---"

# Update Homebrew
echo ""
echo "Updating Homebrew..."
brew update

# Upgrade Homebrew packages
echo ""
echo "Upgrading Homebrew packages..."

# Formula
echo "Upgrading formulas"
if brew list --formula -1 | grep -q .; then
  brew upgrade --formula
else
  echo "No formulas to upgrade"
fi

# Cask
echo "Upgrading casks"
if brew list --cask -1 | grep -q .; then
  brew upgrade --cask
else
  echo "No casks to upgrade"
fi

# Clean up Homebrew
echo ""
echo "Cleaning up Homebrew..."
brew cleanup --prune=all --scrub

echo ""
echo "--- Homebrew Maintenance Completed ---"
