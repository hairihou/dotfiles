return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>b", group = "Buffer" },
      { "<leader>f", group = "Find" },
      { "<leader>g", group = "Git" },
      { "gs", group = "Surround" },
    },
  },
}
