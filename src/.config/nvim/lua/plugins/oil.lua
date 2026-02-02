return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", "<cmd>Oil<cr>", desc = "File Explorer" },
  },
  lazy = false,
  opts = {
    keymaps = {
      ["-"] = "actions.parent",
      ["<CR>"] = "actions.select",
      ["<Esc>"] = "actions.close",
      ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
    view_options = {
      show_hidden = true,
    },
  },
}
