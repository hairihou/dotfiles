#!bin/sh

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation left
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 60

killall Dock
