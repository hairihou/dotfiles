return {
  "toppair/peek.nvim",
  build = "deno task --quiet build:fast",
  config = function()
    require("peek").setup()
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  end,
  event = { "VeryLazy" },
  keys = {
    { "<leader>mp", function()
      local peek = require("peek")
      if peek.is_open() then peek.close() else peek.open() end
    end, desc = "Markdown Preview" },
  },
}
