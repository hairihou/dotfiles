local wezterm = require("wezterm")
local config = wezterm.config_builder()
local gray = {
  [50] = "#f9fafb", [100] = "#f3f4f6", [200] = "#e5e7eb", [300] = "#d1d5dc",
  [400] = "#99a1af", [500] = "#6a7282", [600] = "#4a5567", [700] = "#364153",
  [800] = "#1e2939", [900] = "#101828", [950] = "#030712",
}
local is_transparent = false
wezterm.on("toggle-opacity", function(window, _)
  is_transparent = not is_transparent
  window:set_config_overrides({ window_background_opacity = is_transparent and 0.5 or 1.0 })
end)
config.colors = {
  ansi = {
    "#ffffff", "#ff637e", "#00d492", "#ffb900",
    "#2b7fff", "#c27aff", "#00d3f3", "#cad5e2",
  },
  background = gray[900],
  brights = {
    "#90a1b9", "#ffa1ad", "#5ee9b5", "#ffd230",
    "#51a2ff", "#dab2ff", "#53eafd", "#ffffff",
  },
  cursor_bg = gray[50],
  cursor_border = gray[50],
  cursor_fg = gray[900],
  foreground = gray[100],
  selection_bg = gray[700],
  selection_fg = gray[100],
  tab_bar = {
    active_tab = { bg_color = gray[800], fg_color = gray[100] },
    background = gray[900],
    inactive_tab = { bg_color = gray[900], fg_color = gray[500] },
    inactive_tab_hover = { bg_color = gray[800], fg_color = gray[300] },
    new_tab = { bg_color = gray[900], fg_color = gray[500] },
    new_tab_hover = { bg_color = gray[800], fg_color = gray[300] },
  },
}
config.font = wezterm.font("UDEV Gothic 35NFLG")
config.font_size = 12.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 160
config.initial_rows = 48
config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b[13;2u") },
  { key = "o", mods = "CMD|SHIFT", action = wezterm.action.EmitEvent("toggle-opacity") },
}
config.native_macos_fullscreen_mode = false
config.scrollback_lines = 10000
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.show_close_tab_button_in_tabs = false
config.show_new_tab_button_in_tab_bar = false
config.use_ime = true
config.warn_about_missing_glyphs = false
return config
