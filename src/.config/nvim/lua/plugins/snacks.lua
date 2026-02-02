return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
  },
  lazy = false,
  opts = {
    picker = { enabled = true },
  },
  priority = 1000,
}
