return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()
    local set = vim.keymap.set
    set({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "Add cursor on next match" })
    set({ "n", "x" }, "<C-p>", function() mc.matchAddCursor(-1) end, { desc = "Add cursor on prev match" })
    set({ "n", "x" }, "<C-q>", function() mc.toggleCursor() end, { desc = "Toggle cursor" })
    mc.addKeymapLayer(function(layerSet)
      layerSet({ "n", "x" }, "<C-x>", function() mc.matchSkipCursor(1) end)
      layerSet("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
