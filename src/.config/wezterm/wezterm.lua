local wezterm = require("wezterm")
local config = wezterm.config_builder()

local theme = {
  bg = "#0f172a",
  bg_subtle = "#1e293b",
  bg_emphasis = "#334155",
  fg = "#e2e8f0",
  fg_muted = "#94a3b8",
  fg_emphasis = "#f1f5f9",
  fg_on_emphasis = "#f8fafc",
  ansi = {
    black = "#475569",
    red = "#f87171",
    green = "#4ade80",
    yellow = "#fbbf24",
    blue = "#60a5fa",
    magenta = "#f472b6",
    cyan = "#22d3ee",
    white = "#cbd5e1",
  },
  ansi_bright = {
    black = "#64748b",
    red = "#fca5a5",
    green = "#86efac",
    yellow = "#fcd34d",
    blue = "#93c5fd",
    magenta = "#f9a8d4",
    cyan = "#67e8f9",
    white = "#f1f5f9",
  },
}

config.colors = {
  ansi = {
    theme.ansi.black, theme.ansi.red, theme.ansi.green, theme.ansi.yellow,
    theme.ansi.blue, theme.ansi.magenta, theme.ansi.cyan, theme.ansi.white,
  },
  background = theme.bg,
  brights = {
    theme.ansi_bright.black, theme.ansi_bright.red, theme.ansi_bright.green, theme.ansi_bright.yellow,
    theme.ansi_bright.blue, theme.ansi_bright.magenta, theme.ansi_bright.cyan, theme.ansi_bright.white,
  },
  cursor_bg = theme.fg_on_emphasis,
  cursor_border = theme.fg_on_emphasis,
  cursor_fg = theme.bg,
  foreground = theme.fg,
  selection_bg = theme.bg_emphasis,
  selection_fg = theme.fg_emphasis,
  tab_bar = {
    background = theme.bg,
    active_tab = { bg_color = theme.bg_emphasis, fg_color = theme.fg_emphasis },
    inactive_tab = { bg_color = theme.bg_subtle, fg_color = theme.fg_muted },
    inactive_tab_hover = { bg_color = theme.bg_emphasis, fg_color = theme.fg },
    new_tab = { bg_color = theme.bg_subtle, fg_color = theme.fg_muted },
    new_tab_hover = { bg_color = theme.bg_emphasis, fg_color = theme.fg },
  },
}
config.default_cursor_style = "SteadyBlock"
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
config.window_background_opacity = 0.90
config.window_close_confirmation = "NeverPrompt"

return config
