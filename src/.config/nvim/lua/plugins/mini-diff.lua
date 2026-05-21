return {
  "echasnovski/mini.diff",
  event = { "BufNewFile", "BufReadPre" },
  keys = {
    { "<leader>gd", function() require("mini.diff").toggle_overlay() end, desc = "Toggle Diff Overlay" },
  },
  opts = {},
}
