local web = { "oxfmt", "prettier", stop_after_first = true }
return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  event = { "BufWritePre" },
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true }) end,
      mode = { "n", "v" },
      desc = "Format",
    },
  },
  opts = {
    default_format_opts = { lsp_format = "never" },
    format_on_save = { timeout_ms = 500 },
    formatters = {
      ruff_format = {
        command = "uv",
        prepend_args = { "run", "--no-sync", "ruff" },
      },
    },
    formatters_by_ft = {
      css = web,
      go = { "gofmt" },
      graphql = web,
      html = web,
      javascript = web,
      javascriptreact = web,
      json = web,
      jsonc = web,
      markdown = web,
      python = { "ruff_format" },
      toml = web,
      typescript = web,
      typescriptreact = web,
      vue = web,
      yaml = web,
    },
  },
}
