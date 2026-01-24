local wezterm = require("wezterm")
local config = wezterm.config_builder()

local theme = {
  amber = { [300] = "#fcd34d", [400] = "#fbbf24" },
  blue = { [300] = "#93c5fd", [400] = "#60a5fa" },
  cyan = { [300] = "#67e8f9", [400] = "#22d3ee" },
  green = { [300] = "#86efac", [400] = "#4ade80" },
  pink = { [300] = "#f9a8d4", [400] = "#f472b6" },
  red = { [300] = "#fca5a5", [400] = "#f87171" },
  slate = {
    [50] = "#f8fafc", [100] = "#f1f5f9", [200] = "#e2e8f0", [300] = "#cbd5e1",
    [400] = "#94a3b8", [500] = "#64748b", [600] = "#475569", [700] = "#334155",
    [800] = "#1e293b", [900] = "#0f172a",
  },
}

config.colors = {
  ansi = {
    theme.slate[600], theme.red[400], theme.green[400], theme.amber[400],
    theme.blue[400], theme.pink[400], theme.cyan[400], theme.slate[300],
  },
  background = theme.slate[900],
  brights = {
    theme.slate[500], theme.red[300], theme.green[300], theme.amber[300],
    theme.blue[300], theme.pink[300], theme.cyan[300], theme.slate[100],
  },
  cursor_bg = theme.slate[50],
  cursor_fg = theme.slate[900],
  foreground = theme.slate[200],
  selection_bg = theme.slate[700],
  selection_fg = theme.slate[100],
  tab_bar = {
    active_tab = { bg_color = theme.slate[700], fg_color = theme.slate[100] },
    background = theme.slate[900],
    inactive_tab = { bg_color = theme.slate[800], fg_color = theme.slate[400] },
    inactive_tab_hover = { bg_color = theme.slate[700], fg_color = theme.slate[200] },
    new_tab = { bg_color = theme.slate[800], fg_color = theme.slate[400] },
    new_tab_hover = { bg_color = theme.slate[700], fg_color = theme.slate[200] },
  },
}
config.default_cursor_style = "SteadyBlock"
config.font = wezterm.font("UDEV Gothic 35NFLG")
config.font_size = 14.0
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 128
config.initial_rows = 40
config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b[13;2u") },
}
config.native_macos_fullscreen_mode = false
config.scrollback_lines = 10000
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.use_fancy_tab_bar = false
config.warn_about_missing_glyphs = false
config.window_background_opacity = 0.96
config.window_close_confirmation = "NeverPrompt"

return config
