#!/usr/bin/env -S deno run --allow-all
import $ from 'jsr:@david/dax';

const Tasks = {
  zshrc: async (): Promise<void> => {
    await $`cp ~/dotfiles/.zshrc ~/.zshrc`;
  },
  'zshrc:dump': async (): Promise<void> => {
    await $`cp ~/.zshrc ~/dotfiles/.zshrc`;
  },
  gitconfig: async (): Promise<void> => {
    await $`rsync -au ~/dotfiles/.config/.gitconfig ~/`;
  },
  'gitconfig:dump': async (): Promise<void> => {
    await $`rsync -au ~/.gitconfig ~/dotfiles/.config/`;
  },
  gitignore: async (): Promise<void> => {
    await $`rsync -au ~/dotfiles/.config/git/ignore ~/.config/git/`;
  },
  'gitignore:dump': async (): Promise<void> => {
    await $`rsync -au ~/.config/git/ignore ~/dotfiles/.config/git/`;
  },
  mise: async (): Promise<void> => {
    await $`rsync -au ~/dotfiles/.config/mise/config.toml ~/.config/mise/`;
  },
  'mise:dump': async (): Promise<void> => {
    await $`rsync -au ~/.config/mise/config.toml ~/dotfiles/.config/mise/`;
  },
  'code:settings_json': async (): Promise<void> => {
    await $`rsync -au ~/dotfiles/.vscode/global/settings.json ~/Library/Application\\ Support/Code/User/`;
  },
  'code:settings_json:dump': async (): Promise<void> => {
    await $`rsync -au ~/Library/Application\\ Support/Code/User/settings.json ~/dotfiles/.vscode/global/`;
  },
  all: async (): Promise<void> => {
    await Tasks.zshrc();
    await Tasks.gitignore();
    await Tasks.mise();
    await Tasks['code:settings_json']();
  },
  'all:dump': async (): Promise<void> => {
    await Tasks['zshrc:dump']();
    await Tasks['gitignore:dump']();
    await Tasks['mise:dump']();
    await Tasks['code:settings_json:dump']();
  },
} as const;

const TaskName = Deno.args[0];

if (!TaskName || !(TaskName in Tasks)) {
  console.log('Usage: deno run -A tasks.ts <task>');
  console.log('Available tasks:');
  for (const name of Object.keys(Tasks)) {
    console.log(`\u0020\u0020${name}`);
  }
  Deno.exit(1);
}

await Tasks[TaskName as keyof typeof Tasks]();
