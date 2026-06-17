vim.diagnostic.config({
  jump = { float = true },
  severity_sort = true,
  virtual_lines = { current_line = true },
  virtual_text = { current_line = false },
})
vim.lsp.config("*", {
  root_markers = { ".git" },
})
vim.lsp.enable("ty")
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.lsp", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        autotrigger = true,
      })
    end
  end,
})
