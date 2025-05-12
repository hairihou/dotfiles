#!/usr/bin/env -S deno run --allow-all
import $ from 'jsr:@david/dax';

await $`defaults write com.apple.dock autohide -bool true`;
await $`defaults write com.apple.dock magnification -bool false`;
await $`defaults write com.apple.dock orientation left`;
await $`defaults write com.apple.dock show-recents -bool false`;
await $`defaults write com.apple.dock tilesize -int 60`;

await $`killall Dock`;
