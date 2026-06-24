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
    { "<leader>gB", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>go", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Git Browse" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
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
