local theme = {
  amber400 = "#ffb900",
  blue400 = "#51a2ff",
  cyan300 = "#74d4ff",
  fuchsia300 = "#f4a8ff",
  gray50 = "#f9fafb",
  gray300 = "#d1d5dc",
  gray500 = "#6a7282",
  gray700 = "#364153",
  gray800 = "#1e2939",
  gray950 = "#030712",
  indigo300 = "#a3b3ff",
  pink400 = "#fb64b6",
  red400 = "#ff6467",
  teal300 = "#46ecd5",
}
local hl = function(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end
-- syntax
hl("Comment", { fg = theme.gray500, italic = true })
hl("Constant", { fg = theme.pink400 })
hl("Delimiter", { fg = theme.gray500 })
hl("Special", { fg = theme.fuchsia300 })
hl("Statement", { fg = theme.indigo300 })
hl("String", { fg = theme.cyan300 })
hl("Type", { fg = theme.teal300 })
-- ui
hl("CursorColumn", { bg = theme.gray800 })
hl("CursorLine", { bg = theme.gray800 })
hl("CursorLineNr", { bold = true })
hl("FloatBorder", { fg = theme.gray700 })
hl("IncSearch", { fg = theme.gray800, bg = theme.amber400 })
hl("LineNr", { fg = theme.gray500 })
hl("Normal", { bg = "NONE" })
hl("NormalFloat", { link = "Normal" })
hl("PmenuBorder", { fg = theme.gray700 })
hl("PmenuSel", { fg = theme.gray50, bg = theme.gray700 })
hl("Search", { fg = theme.gray800, bg = theme.amber400 })
hl("StatusLine", { bg = "NONE" })
hl("Visual", { bg = theme.gray700 })
hl("WinBar", { bg = "NONE" })
hl("WinSeparator", { fg = theme.gray800 })
-- mini.icons
hl("MiniIconsAzure", { fg = theme.blue400 })
hl("MiniIconsBlue", { fg = theme.blue400 })
hl("MiniIconsCyan", { fg = theme.cyan300 })
hl("MiniIconsGreen", { fg = theme.teal300 })
hl("MiniIconsGrey", { link = "Normal" })
hl("MiniIconsOrange", { fg = theme.amber400 })
hl("MiniIconsPurple", { fg = theme.fuchsia300 })
hl("MiniIconsRed", { fg = theme.red400 })
hl("MiniIconsYellow", { fg = theme.amber400 })
-- render-markdown
hl("RenderMarkdownH", { fg = theme.blue400, bold = true })
hl("RenderMarkdownHBg", { bg = theme.gray950 })
hl("RenderMarkdownCode", { bg = theme.gray800 })
hl("RenderMarkdownCodeInline", { fg = theme.cyan300, bg = theme.gray800 })
-- treesitter
hl("@markup.raw", { fg = theme.gray300 })
hl("@markup.raw.block", { fg = theme.gray300 })
hl("@punctuation.bracket", { fg = theme.gray500 })
hl("@type.builtin", { italic = true })
