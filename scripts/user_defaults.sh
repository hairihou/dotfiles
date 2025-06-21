#!/bin/zsh

set -eu

echo "🔧 Configuring macOS Dock settings..."

# Dock settings based on src/user-defaults.ts
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 60

echo "✅ All Dock settings applied successfully"

echo "🔄 Restarting Dock to apply changes..."
killall Dock

echo "🎉 Dock configuration completed successfully"
