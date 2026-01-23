local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.colors = {
  ansi = { "#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#bac2de" },
  background = "#1e293d",
  brights = { "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8" },
  cursor_bg = "#f5e0dc",
  cursor_border = "#f5e0dc",
  cursor_fg = "#1e293d",
  foreground = "#cdd6f4",
  selection_bg = "#585b70",
  selection_fg = "#cdd6f4",
}
config.default_cursor_style = "BlinkingBar"
config.font = wezterm.font("UDEV Gothic 35NFLG")
config.font_size = 14.0
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 120
config.initial_rows = 36
config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
}
config.macos_window_background_blur = 20
config.native_macos_fullscreen_mode = false
config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.80
config.window_close_confirmation = "NeverPrompt"

return config
