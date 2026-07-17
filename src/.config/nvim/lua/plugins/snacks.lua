return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols" },
    { "<leader>fw", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep Word" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
  lazy = false,
  opts = {
    indent = {},
    picker = {
      sources = {
        files = { hidden = true },
      },
    },
  },
  priority = 1000,
}
