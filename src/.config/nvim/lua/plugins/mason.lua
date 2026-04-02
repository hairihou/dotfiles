return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "basedpyright",
        "gopls",
        "lua_ls",
        "ts_ls",
        "vue_ls",
      },
    },
  },
}
