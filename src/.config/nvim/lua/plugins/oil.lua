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
    },
    use_default_keymaps = false,
    view_options = {
      is_hidden_file = function(name, _)
        return name == ".git" or name == ".DS_Store"
      end,
    },
  },
}
