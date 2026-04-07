local z = {
  bg1 = "#1e2939",
  bg2 = "#364153",
  fg = "#f9fafb",
  fg1 = "#d1d5dc",
  fg2 = "#6a7282",
  blue = "#51a2ff",
  cyan = "#74d4ff",
  green = "#46ecd5",
  indigo = "#a3b3ff",
  pink = "#fb64b6",
  purple = "#f4a8ff",
  red = "#ff6467",
  yellow = "#ffb900",
}
local hl = function(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end
-- syntax
hl("Comment", { fg = z.fg2, italic = true })
hl("Constant", { fg = z.pink })
hl("Delimiter", { fg = z.fg2 })
hl("Special", { fg = z.purple })
hl("Statement", { fg = z.indigo })
hl("String", { fg = z.cyan })
hl("Type", { fg = z.green })
-- ui
hl("CursorColumn", { bg = z.bg1 })
hl("CursorLine", { bg = z.bg1 })
hl("CursorLineNr", { bold = true })
hl("FloatBorder", { fg = z.bg2 })
hl("IncSearch", { fg = z.bg1, bg = z.yellow })
hl("LineNr", { fg = z.fg2 })
hl("Normal", { bg = "NONE" })
hl("NormalFloat", { link = "Normal" })
hl("PmenuBorder", { fg = z.bg2 })
hl("PmenuSel", { fg = z.fg, bg = z.bg2 })
hl("Search", { fg = z.bg1, bg = z.yellow })
hl("StatusLine", { bg = "NONE" })
hl("Visual", { bg = z.bg2 })
hl("WinBar", { bg = "NONE" })
hl("WinSeparator", { fg = z.bg1 })
-- mini.icons
hl("MiniIconsAzure", { fg = z.blue })
hl("MiniIconsBlue", { fg = z.blue })
hl("MiniIconsCyan", { fg = z.cyan })
hl("MiniIconsGreen", { fg = z.green })
hl("MiniIconsGrey", { link = "Normal" })
hl("MiniIconsOrange", { fg = z.yellow })
hl("MiniIconsPurple", { fg = z.purple })
hl("MiniIconsRed", { fg = z.red })
hl("MiniIconsYellow", { fg = z.yellow })
-- render-markdown
hl("RenderMarkdownH", { fg = z.blue, bold = true })
hl("RenderMarkdownHBg", { bg = "#030712" })
hl("RenderMarkdownCode", { bg = z.bg1 })
hl("RenderMarkdownCodeInline", { fg = z.cyan, bg = z.bg1 })
-- treesitter
hl("@markup.raw", { fg = z.fg1 })
hl("@markup.raw.block", { fg = z.fg1 })
hl("@punctuation.bracket", { fg = z.fg2 })
hl("@type.builtin", { italic = true })
