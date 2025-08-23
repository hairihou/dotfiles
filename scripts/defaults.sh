#!/bin/bash
set -euo pipefail

echo "--- Configuring defaults ---"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write com.apple.HIToolbox AppleFnUsageType -int 0

defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

killall Dock

echo "--- Configuration completed successfully ---"
