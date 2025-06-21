#!/bin/zsh
set -euo pipefail

echo "--- Configuring macOS Dock settings ---"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 60

killall Dock

echo "--- Dock configuration completed successfully ---"
