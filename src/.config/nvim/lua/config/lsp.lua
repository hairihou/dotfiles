vim.diagnostic.config({
  jump = { float = true },
  severity_sort = true,
  virtual_lines = { current_line = true },
  virtual_text = { current_line = false },
})
vim.lsp.config("*", {
  root_markers = { ".git" },
})
vim.lsp.enable({ "angularls", "gopls", "lua_ls", "oxlint", "ty", "vtsls", "vue_ls" })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(ev)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to Definition" })
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, { bufnr = ev.buf })
    end
  end,
})
