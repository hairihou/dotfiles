local palettes = {
  dark = {
    add = "#68cb9a",
    code_bg = "#212a3b",
    constant = "#ee94bc",
    cursorline = "#212a3b",
    error = "#f6939b",
    fg = "#e6e8ec",
    func = "#99dfd6",
    heading_bg = "#050b18",
    identifier = "#f9fafc",
    info = "#84b6ff",
    muted = "#9da3af",
    pmenusel_bg = "#384151",
    raw = "#c6cbd3",
    search_bg = "#d7ae53",
    search_fg = "#212a3b",
    special = "#e8c0ea",
    statement = "#c4ccff",
    string = "#a0d9f7",
    tag = "#f6bdd4",
    visual_bg = "#4f5766",
    visual_fg = "#f2f3f6",
    warn = "#d7ae53",
  },
  light = {
    add = "#266044",
    code_bg = "#f1ebdf",
    constant = "#734057",
    cursorline = "#f1ebdf",
    error = "#774045",
    fg = "#231f17",
    func = "#034e48",
    heading_bg = "#f1ebdf",
    identifier = "#13100a",
    info = "#2c4466",
    muted = "#59554c",
    pmenusel_bg = "#e5dfd2",
    raw = "#48433a",
    search_bg = "#fadb90",
    search_fg = "#231f17",
    special = "#68446a",
    statement = "#494e7d",
    string = "#154960",
    tag = "#5e3447",
    visual_bg = "#d3cdc1",
    visual_fg = "#231f17",
    warn = "#534013",
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
