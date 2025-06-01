#!/usr/bin/env -S deno run --allow-all
import $ from 'jsr:@david/dax';

/**
 * macOS Dock configuration settings
 */
const DockSettings = {
  autohide: true,
  magnification: false,
  orientation: 'left',
  'show-recents': false,
  tilesize: 60,
} as const;

/**
 * macOS default value types
 */
const DefaultValueTypes = {
  bool: '-bool',
  int: '-int',
  string: '',
} as const;

type DefaultValueType = keyof typeof DefaultValueTypes;

/**
 * Result type for error handling without throwing
 */
type Result<TValue, TError extends Error> =
  | { readonly ok: true; readonly value: TValue }
  | { readonly ok: false; readonly error: TError };

interface DockSetting {
  readonly key: string;
  readonly value: string | number | boolean;
  readonly type: DefaultValueType;
}

/**
 * Converts DockSettings to structured format with type information
 */
const getDockSettingsArray = (): readonly DockSetting[] => {
  return Object.entries(DockSettings).map(([key, value]) => ({
    key,
    value,
    type: typeof value === 'boolean' ? 'bool' : typeof value === 'number' ? 'int' : 'string',
  }));
};

/**
 * Applies a single macOS default setting using the defaults command
 */
const applyDefaultSetting = async (
  domain: string,
  setting: DockSetting,
): Promise<Result<void, Error>> => {
  try {
    const typeFlag = DefaultValueTypes[setting.type];
    const args = typeFlag
      ? ['defaults', 'write', domain, setting.key, typeFlag, String(setting.value)]
      : ['defaults', 'write', domain, setting.key, String(setting.value)];

    await $`${args}`;
    return { ok: true, value: undefined };
  } catch (error) {
    return {
      ok: false,
      error: new Error(`Failed to set ${setting.key}: ${(error as Error).message}`),
    };
  }
};

/**
 * Restarts the Dock application to apply changes
 */
const restartDock = async (): Promise<Result<void, Error>> => {
  try {
    await $`killall Dock`;
    return { ok: true, value: undefined };
  } catch (error) {
    return {
      ok: false,
      error: new Error(`Failed to restart Dock: ${(error as Error).message}`),
    };
  }
};

/**
 * Logs operation results and handles failures
 */
const handleResults = (results: readonly Result<void, Error>[]): boolean => {
  const failures = results.filter((result) => !result.ok);

  if (failures.length > 0) {
    console.error('❌ Failed to apply some Dock settings:');
    const errorMessages = failures
      .filter((failure): failure is { readonly ok: false; readonly error: Error } => !failure.ok)
      .map((failure) => `  • ${failure.error.message}`);

    errorMessages.map((message) => console.error(message));
    return false;
  }

  console.log('✅ All Dock settings applied successfully');
  return true;
};

/**
 * Main function to configure macOS Dock settings
 */
const configureDock = async (): Promise<void> => {
  console.log('🔧 Configuring macOS Dock settings...');

  const settings = getDockSettingsArray();
  const dockDomain = 'com.apple.dock';

  // Apply all settings in parallel for better performance
  const settingsPromises = settings.map((setting) => applyDefaultSetting(dockDomain, setting));

  const results = await Promise.all(settingsPromises);
  const success = handleResults(results);

  if (!success) {
    console.error('❌ Configuration failed');
    Deno.exit(1);
  }

  // Restart Dock to apply changes
  console.log('🔄 Restarting Dock to apply changes...');
  const restartResult = await restartDock();

  if (!restartResult.ok) {
    console.error(`❌ ${restartResult.error.message}`);
    Deno.exit(1);
  }

  console.log('🎉 Dock configuration completed successfully');
};

// Execute the configuration
await configureDock();
