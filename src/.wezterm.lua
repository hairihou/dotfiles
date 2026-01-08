local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.colors = {
  foreground = '#CDD6F4',
  background = '#1D283D',
  cursor_bg = '#F5E0DC',
  cursor_fg = '#1D283D',
  cursor_border = '#F5E0DC',
  selection_bg = '#585B70',
  selection_fg = '#CDD6F4',
  ansi = {
    '#45475A', -- black
    '#F38BA8', -- red
    '#A6E3A1', -- green
    '#F9E2AF', -- yellow
    '#89B4FA', -- blue
    '#F5C2E7', -- magenta
    '#94E2D5', -- cyan
    '#BAC2DE', -- white
  },
  brights = {
    '#585B70', -- bright black
    '#F38BA8', -- bright red
    '#A6E3A1', -- bright green
    '#F9E2AF', -- bright yellow
    '#89B4FA', -- bright blue
    '#F5C2E7', -- bright magenta
    '#94E2D5', -- bright cyan
    '#A6ADC8', -- bright white
  },
}
config.cursor_blink_rate = 500
config.default_cursor_style = 'BlinkingBar'
config.font = wezterm.font 'UDEV Gothic 35NFLG'
config.font_size = 12
config.initial_cols = 120
config.initial_rows = 48
config.macos_window_background_blur = 20
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.use_ime = true
config.window_background_opacity = 0.96
config.window_close_confirmation = 'NeverPrompt'

return config
