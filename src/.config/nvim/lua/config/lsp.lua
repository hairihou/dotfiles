vim.diagnostic.config({
  jump = { float = true },
  severity_sort = true,
  virtual_lines = { current_line = true },
  virtual_text = { current_line = false },
})
vim.lsp.config("*", {
  root_markers = { ".git" },
})
vim.lsp.enable({ "gopls", "lua_ls", "oxlint", "ty", "vtsls", "vue_ls" })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to Definition" })
  end,
})
