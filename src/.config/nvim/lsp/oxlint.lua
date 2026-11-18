local function project_oxlint(root_dir)
  local dir = root_dir
  while dir do
    local bin = vim.fs.joinpath(dir, "node_modules/.bin/oxlint")
    if vim.uv.fs_stat(bin) then
      return bin
    end
    local parent = vim.fs.dirname(dir)
    dir = parent ~= dir and parent or nil
  end
end

return {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ project_oxlint(config.root_dir), "--lsp" }, dispatchers)
  end,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  root_dir = function(bufnr, on_dir)
    local root_dir = vim.fs.root(bufnr, { ".oxlintrc.json", "oxlint.config.ts" })
    if root_dir and project_oxlint(root_dir) then
      on_dir(root_dir)
    end
  end,
}
