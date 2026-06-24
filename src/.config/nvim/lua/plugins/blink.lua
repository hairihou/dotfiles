return {
  "saghen/blink.cmp",
  version = "1.*",
  lazy = false,
  opts = {
    keymap = { preset = "default" },
    completion = {
      documentation = { auto_show = true },
    },
    signature = { enabled = true },
  },
  config = function(_, opts)
    local blink = require("blink.cmp")
    blink.setup(opts)
    vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
  end,
}
