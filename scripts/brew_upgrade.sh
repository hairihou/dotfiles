#!/bin/zsh

set -eu

echo "Upgrading Homebrew packages"

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
