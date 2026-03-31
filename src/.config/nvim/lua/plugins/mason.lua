return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      automatic_enable = true,
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
