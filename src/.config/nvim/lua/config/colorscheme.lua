local tw = {
  amber300 = "#ffd230",
  amber400 = "#ffb900",
  amber800 = "#973c00",
  blue400 = "#51a2ff",
  blue700 = "#1447e6",
  emerald400 = "#00d492",
  emerald700 = "#007a55",
  fuchsia300 = "#f4a8ff",
  fuchsia700 = "#a800b7",
  gray50 = "#f9fafb",
  gray100 = "#f3f4f6",
  gray200 = "#e5e7eb",
  gray300 = "#d1d5dc",
  gray400 = "#99a1af",
  gray500 = "#6a7282",
  gray600 = "#4a5565",
  gray700 = "#364153",
  gray800 = "#1e2939",
  gray900 = "#101828",
  gray950 = "#030712",
  indigo300 = "#a3b3ff",
  indigo600 = "#4f39f6",
  pink300 = "#fda5d5",
  pink400 = "#fb64b6",
  pink700 = "#c6005c",
  pink800 = "#a3004c",
  rose400 = "#ff637e",
  rose700 = "#c70036",
  sky300 = "#74d4ff",
  sky700 = "#0069a8",
  teal300 = "#46ecd5",
  teal800 = "#005f5a",
  white = "#ffffff",
}

local palettes = {
  dark = {
    add = tw.emerald400,
    code_bg = tw.gray800,
    constant = tw.pink400,
    cursorline = tw.gray800,
    error = tw.rose400,
    fg = tw.gray100,
    func = tw.teal300,
    heading_bg = tw.gray950,
    identifier = tw.white,
    info = tw.blue400,
    muted = tw.gray400,
    pmenusel_bg = tw.gray700,
    raw = tw.gray300,
    search_bg = tw.amber400,
    search_fg = tw.gray800,
    special = tw.fuchsia300,
    statement = tw.indigo300,
    string = tw.sky300,
    tag = tw.pink300,
    visual_bg = tw.gray500,
    visual_fg = tw.gray50,
    warn = tw.amber400,
  },
  light = {
    add = tw.emerald700,
    code_bg = tw.gray100,
    constant = tw.pink700,
    cursorline = tw.gray100,
    error = tw.rose700,
    fg = tw.gray900,
    func = tw.teal800,
    heading_bg = tw.gray100,
    identifier = tw.gray950,
    info = tw.blue700,
    muted = tw.gray600,
    pmenusel_bg = tw.gray200,
    raw = tw.gray700,
    search_bg = tw.amber300,
    search_fg = tw.gray900,
    special = tw.fuchsia700,
    statement = tw.indigo600,
    string = tw.sky700,
    tag = tw.pink800,
    visual_bg = tw.gray500,
    visual_fg = tw.gray50,
    warn = tw.amber800,
  },
}

local hl = function(name, opts)
  vim.api.nvim_set_hl(0, name, opts)
end

local apply = function()
  local c = palettes[vim.o.background]
  -- syntax
  hl("Comment", { fg = c.muted, italic = true })
  hl("Constant", { fg = c.constant })
  hl("Delimiter", { fg = c.muted })
  hl("Function", { fg = c.func })
  hl("Identifier", { fg = c.identifier })
  hl("Special", { fg = c.special })
  hl("Statement", { fg = c.statement })
  hl("String", { fg = c.string })
  hl("Tag", { fg = c.tag })
  hl("Type", { fg = c.func })
  -- ui
  hl("CursorLine", { bg = c.cursorline })
  hl("CursorLineNr", { bold = true })
  hl("Directory", { fg = c.fg })
  hl("FloatBorder", { fg = c.muted })
  hl("IncSearch", { fg = c.search_fg, bg = c.search_bg })
  hl("LineNr", { fg = c.muted })
  hl("Normal", { bg = "NONE" })
  hl("NormalFloat", { link = "Normal" })
  hl("PmenuBorder", { fg = c.muted })
  hl("PmenuSel", { fg = c.fg, bg = c.pmenusel_bg })
  hl("Search", { fg = c.search_fg, bg = c.search_bg })
  hl("StatusLine", { bg = "NONE" })
  hl("Visual", { fg = c.visual_fg, bg = c.visual_bg })
  hl("WinBar", { bg = "NONE" })
  hl("WinSeparator", { fg = c.muted })
  -- diagnostics
  hl("DiagnosticError", { fg = c.error })
  hl("DiagnosticWarn", { fg = c.warn })
  hl("DiagnosticInfo", { fg = c.info })
  hl("DiagnosticHint", { fg = c.muted })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warn })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.muted })
  -- mini.diff
  hl("MiniDiffSignAdd", { fg = c.add })
  hl("MiniDiffSignChange", { fg = c.info })
  hl("MiniDiffSignDelete", { fg = c.error })
  -- mini.icons
  for _, name in ipairs({
    "MiniIconsAzure",
    "MiniIconsBlue",
    "MiniIconsCyan",
    "MiniIconsGreen",
    "MiniIconsGrey",
    "MiniIconsOrange",
    "MiniIconsPurple",
    "MiniIconsRed",
    "MiniIconsYellow",
  }) do
    hl(name, { fg = c.muted })
  end
  -- render-markdown
  hl("RenderMarkdownH", { fg = c.info, bold = true })
  hl("RenderMarkdownHBg", { bg = c.heading_bg })
  hl("RenderMarkdownCode", { bg = c.code_bg })
  hl("RenderMarkdownCodeInline", { fg = c.string, bg = c.code_bg })
  -- treesitter
  hl("@markup.raw", { fg = c.raw })
  hl("@markup.raw.block", { fg = c.raw })
  hl("@punctuation.bracket", { fg = c.muted })
  hl("@tag.attribute", { fg = c.raw })
  hl("@tag.delimiter", { fg = c.muted })
  hl("@type.builtin", { italic = true })
end

apply()
-- Observed on NVIM v0.12.6: OptionSet does not fire for 'background' changes made during startup,
-- and default highlights are reloaded after OptionSet fires, so apply runs on VimEnter and on the next tick.
vim.api.nvim_create_autocmd("VimEnter", { callback = apply })
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    vim.schedule(apply)
  end,
})
