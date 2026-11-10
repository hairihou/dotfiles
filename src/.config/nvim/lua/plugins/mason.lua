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
        "angularls",
        "lua_ls",
        "oxlint",
        "vtsls",
        "vue_ls",
      },
    },
  },
}
