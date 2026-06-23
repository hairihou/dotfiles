return {
  "echasnovski/mini.diff",
  event = { "BufNewFile", "BufReadPre" },
  keys = {
    {
      "<leader>gd",
      function()
        local diff = require("mini.diff")
        if diff.get_buf_data(0) then
          diff.toggle_overlay(0)
        else
          vim.notify("mini.diff: no diff source for this buffer", vim.log.levels.WARN)
        end
      end,
      desc = "Toggle Diff Overlay",
    },
  },
  opts = {},
}
