#!/usr/bin/env -S deno run --allow-all
import $ from 'jsr:@david/dax';

/**
 * Result type for task execution
 */
type TaskResult<TData = void> =
  | { readonly ok: true; readonly data: TData }
  | { readonly ok: false; readonly error: Error };

/**
 * Task definition with metadata
 */
interface TaskDefinition {
  readonly description: string;
  readonly dependencies?: readonly string[];
  readonly parallel?: boolean;
  readonly action: () => Promise<void>;
}

/**
 * Unicode space constants for better visibility
 */
const UnicodeSpaces = {
  /** Regular space (U+0020) */
  Space: '\u0020',
  /** En space (U+2002) - half the width of an em */
  EnSpace: '\u2002',
  /** Figure space (U+2007) - same width as digits */
  FigureSpace: '\u2007',
} as const;

/**
 * Logger utility for consistent output
 */
class Logger {
  private static formatTime(): string {
    return new Date().toLocaleTimeString();
  }

  static info(message: string): void {
    console.log(`[${this.formatTime()}]${UnicodeSpaces.Space}ℹ️${UnicodeSpaces.EnSpace}${message}`);
  }

  static success(message: string): void {
    console.log(`[${this.formatTime()}]${UnicodeSpaces.Space}✅${UnicodeSpaces.Space}${message}`);
  }

  static error(message: string): void {
    console.error(`[${this.formatTime()}]${UnicodeSpaces.Space}❌${UnicodeSpaces.Space}${message}`);
  }

  static warn(message: string): void {
    console.warn(`[${this.formatTime()}]${UnicodeSpaces.Space}⚠️${UnicodeSpaces.EnSpace}${message}`);
  }

  static task(taskName: string): void {
    console.log(
      `[${this.formatTime()}]${UnicodeSpaces.Space}🚀${UnicodeSpaces.Space}Running${UnicodeSpaces.Space}task:${UnicodeSpaces.Space}${taskName}`,
    );
  }
}

/**
 * Sync utility for file operations
 */
class SyncUtil {
  /**
   * Expand path with proper tilde handling
   */
  private static expandPath(path: string): string {
    if (path.startsWith('~/')) {
      return path.replace('~', Deno.env.get('HOME') || '~');
    }
    return path;
  }

  /**
   * Check if a file or directory exists
   */
  static async exists(path: string): Promise<boolean> {
    try {
      const expandedPath = this.expandPath(path);
      await Deno.stat(expandedPath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Sync files from source to destination
   */
  static async sync(source: string, destination: string, description: string): Promise<void> {
    const expandedSource = this.expandPath(source);
    const expandedDestination = this.expandPath(destination);

    // Check if source exists
    if (!(await this.exists(source))) {
      Logger.warn(
        `Skipping${UnicodeSpaces.Space}${description}:${UnicodeSpaces.Space}source${UnicodeSpaces.Space}not${UnicodeSpaces.Space}found${UnicodeSpaces.Space}at${UnicodeSpaces.Space}${source}`,
      );
      return;
    }

    Logger.info(
      `${description}:${UnicodeSpaces.Space}${source}${UnicodeSpaces.Space}→${UnicodeSpaces.Space}${destination}`,
    );
    await $`rsync -av ${expandedSource} ${expandedDestination}`;
  }

  /**
   * Ensure directory exists
   */
  static async ensureDir(path: string): Promise<void> {
    const expandedPath = this.expandPath(path);
    await $`mkdir -p ${expandedPath}`;
  }
}

/**
 * Task execution engine
 */
class TaskRunner {
  private readonly tasks = new Map<string, TaskDefinition>();
  private readonly executed = new Set<string>();

  /**
   * Register a task
   */
  register(name: string, definition: TaskDefinition): void {
    this.tasks.set(name, definition);
  }

  /**
   * Execute a task with dependency resolution
   */
  async run(taskName: string): Promise<TaskResult> {
    try {
      await this.executeTask(taskName);
      return { ok: true, data: undefined };
    } catch (error) {
      return { ok: false, error: error as Error };
    }
  }

  /**
   * Execute task with dependencies
   */
  private async executeTask(taskName: string): Promise<void> {
    if (this.executed.has(taskName)) {
      return;
    }

    const task = this.tasks.get(taskName);
    if (!task) {
      throw new Error(`Task '${taskName}' not found`);
    }

    // Execute dependencies
    if (task.dependencies?.length) {
      if (task.parallel) {
        await Promise.all(
          task.dependencies.map((dep) => this.executeTask(dep)),
        );
      } else {
        for (const dep of task.dependencies) {
          await this.executeTask(dep);
        }
      }
    }

    // Execute the task
    Logger.task(taskName);
    await task.action();
    this.executed.add(taskName);
    Logger.success(`Task '${taskName}' completed`);
  }

  /**
   * List all available tasks
   */
  listTasks(): void {
    console.log(`Available${UnicodeSpaces.Space}tasks:`);
    console.log();

    for (const [name, definition] of this.tasks) {
      console.log(`${UnicodeSpaces.EnSpace}${UnicodeSpaces.EnSpace}${name}`);
      console.log(
        `${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}${definition.description}`,
      );
      if (definition.dependencies?.length) {
        console.log(
          `${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}${UnicodeSpaces.FigureSpace}Dependencies:${UnicodeSpaces.Space}${
            definition.dependencies.join(`,${UnicodeSpaces.Space}`)
          }`,
        );
      }
      console.log();
    }
  }

  /**
   * Get task names for validation
   */
  getTaskNames(): readonly string[] {
    return Array.from(this.tasks.keys());
  }
}

// Initialize task runner
const runner = new TaskRunner();

// Configuration
const Paths = {
  Dotfiles: '~/dotfiles',
  Home: '~',
  Vscode: '~/Library/Application Support/Code/User',
  Config: '~/.config',
} as const;

// Register dotfile sync tasks
runner.register('zshrc', {
  description: 'Sync .zshrc from dotfiles to home',
  action: async () => {
    await SyncUtil.sync(`${Paths.Dotfiles}/.zshrc`, `${Paths.Home}/`, 'Syncing .zshrc');
  },
});

runner.register('zshrc:dump', {
  description: 'Dump .zshrc from home to dotfiles',
  action: async () => {
    await SyncUtil.sync(`${Paths.Home}/.zshrc`, `${Paths.Dotfiles}/`, 'Dumping .zshrc');
  },
});

runner.register('gitconfig', {
  description: 'Sync gitconfig from dotfiles to home',
  action: async () => {
    await SyncUtil.sync(`${Paths.Dotfiles}/.config/.gitconfig`, `${Paths.Home}/`, 'Syncing gitconfig');
  },
});

runner.register('gitconfig:dump', {
  description: 'Dump gitconfig from home to dotfiles',
  action: async () => {
    await SyncUtil.sync(`${Paths.Home}/.gitconfig`, `${Paths.Dotfiles}/.config/`, 'Dumping gitconfig');
  },
});

runner.register('gitignore', {
  description: 'Sync git ignore from dotfiles to config',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Config}/git`);
    await SyncUtil.sync(`${Paths.Dotfiles}/.config/git/ignore`, `${Paths.Config}/git/`, 'Syncing git ignore');
  },
});

runner.register('gitignore:dump', {
  description: 'Dump git ignore from config to dotfiles',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Dotfiles}/.config/git`);
    await SyncUtil.sync(`${Paths.Config}/git/ignore`, `${Paths.Dotfiles}/.config/git/`, 'Dumping git ignore');
  },
});

runner.register('mise', {
  description: 'Sync mise config from dotfiles to config',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Config}/mise`);
    await SyncUtil.sync(`${Paths.Dotfiles}/.config/mise/config.toml`, `${Paths.Config}/mise/`, 'Syncing mise config');
  },
});

runner.register('mise:dump', {
  description: 'Dump mise config from config to dotfiles',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Dotfiles}/.config/mise`);
    await SyncUtil.sync(`${Paths.Config}/mise/config.toml`, `${Paths.Dotfiles}/.config/mise/`, 'Dumping mise config');
  },
});

runner.register('code', {
  description: 'Sync VS Code settings from dotfiles to VS Code',
  action: async () => {
    await SyncUtil.sync(
      `${Paths.Dotfiles}/.vscode/global/settings.json`,
      `${Paths.Vscode}/`,
      'Syncing VS Code settings',
    );
  },
});

runner.register('code:dump', {
  description: 'Dump VS Code settings from VS Code to dotfiles',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Dotfiles}/.vscode/global`);
    await SyncUtil.sync(
      `${Paths.Vscode}/settings.json`,
      `${Paths.Dotfiles}/.vscode/global/`,
      'Dumping VS Code settings',
    );
  },
});

runner.register('code:instructions', {
  description: 'Sync VS Code prompt instructions from dotfiles to VS Code',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Vscode}/prompts`);
    await SyncUtil.sync(
      `${Paths.Dotfiles}/.github/instructions/`,
      `${Paths.Vscode}/prompts/`,
      'Syncing VS Code prompt instructions',
    );
  },
});

runner.register('code:instructions:dump', {
  description: 'Dump VS Code prompt instructions from VS Code to dotfiles',
  action: async () => {
    await SyncUtil.ensureDir(`${Paths.Dotfiles}/.github/instructions`);
    await SyncUtil.sync(
      `${Paths.Vscode}/prompts/`,
      `${Paths.Dotfiles}/.github/instructions/`,
      'Dumping VS Code prompt instructions',
    );
  },
});

// Register composite tasks
runner.register('all', {
  description: 'Sync all dotfiles to system',
  dependencies: ['zshrc', 'gitignore', 'mise', 'code', 'code:instructions'],
  parallel: true,
  action: async () => {
    await Promise.resolve(); // Ensure it returns a Promise
    Logger.info('All dotfiles synced successfully');
  },
});

runner.register('all:dump', {
  description: 'Dump all system configs to dotfiles',
  dependencies: ['zshrc:dump', 'gitignore:dump', 'mise:dump', 'code:dump', 'code:instructions:dump'],
  parallel: true,
  action: async () => {
    await Promise.resolve(); // Ensure it returns a Promise
    Logger.info('All configs dumped successfully');
  },
});

// Register brew tasks
runner.register('brew:update', {
  description: 'Update Homebrew',
  action: async () => {
    Logger.info('Updating Homebrew');
    await $`brew update`;
  },
});

runner.register('brew:upgrade', {
  description: 'Upgrade all Homebrew packages',
  dependencies: ['brew:update'],
  action: async () => {
    for (const option of ['formula', 'cask'] as const) {
      Logger.info(`Upgrading ${option}s`);
      const result = await $`brew list --${option}`.noThrow().stdout('piped');
      if (result.code === 0 && result.stdout.trim()) {
        const packages = result.stdout.trim().split('\n').filter((pkg) => pkg.trim());
        if (packages.length > 0) {
          Logger.info(
            `Found ${packages.length} ${option}(s) to upgrade: ${packages.slice(0, 3).join(', ')}${
              packages.length > 3 ? '...' : ''
            }`,
          );
          await $`brew upgrade --${option} ${packages}`;
        } else {
          Logger.info(`No ${option}s to upgrade`);
        }
      } else {
        Logger.info(`No ${option}s found or command failed`);
      }
    }
  },
});

runner.register('brew:prune', {
  description: 'Clean up Homebrew',
  action: async () => {
    Logger.info('Cleaning up Homebrew');
    await $`brew cleanup --prune=all --scrub`;
  },
});

runner.register('brew:all', {
  description: 'Update, upgrade, and clean Homebrew',
  dependencies: ['brew:update', 'brew:upgrade', 'brew:prune'],
  action: async () => {
    await Promise.resolve(); // Ensure it returns a Promise
    Logger.info('Homebrew maintenance completed');
  },
});

// Main execution
async function main(): Promise<void> {
  const taskName = Deno.args[0];

  if (!taskName || taskName === 'help' || taskName === '--help' || taskName === '-h') {
    console.log(
      `Usage:${UnicodeSpaces.Space}deno${UnicodeSpaces.Space}run${UnicodeSpaces.Space}-A${UnicodeSpaces.Space}tasks.ts${UnicodeSpaces.Space}<task>`,
    );
    console.log();
    runner.listTasks();
    Deno.exit(0);
  }

  const availableTasks = runner.getTaskNames();
  if (!availableTasks.includes(taskName)) {
    Logger.error(`Task${UnicodeSpaces.Space}'${taskName}'${UnicodeSpaces.Space}not${UnicodeSpaces.Space}found`);
    console.log();
    console.log(`Available${UnicodeSpaces.Space}tasks:`);
    for (const name of availableTasks) {
      console.log(`${UnicodeSpaces.EnSpace}${UnicodeSpaces.EnSpace}${name}`);
    }
    Deno.exit(1);
  }

  const result = await runner.run(taskName);
  if (!result.ok) {
    Logger.error(
      `Task${UnicodeSpaces.Space}'${taskName}'${UnicodeSpaces.Space}failed:${UnicodeSpaces.Space}${result.error.message}`,
    );
    Deno.exit(1);
  }
}

if (import.meta.main) {
  await main();
}
