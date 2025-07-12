#!/bin/zsh
set -euo pipefail

echo "--- Configuring macOS settings ---"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 60

defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

killall Dock

echo "--- Configuration completed successfully ---"
