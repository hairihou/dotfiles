local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  { "folke/todo-comments.nvim", opts = {} },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "default" },
      sources = { default = { "lsp", "path", "buffer" } },
    },
  },
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    opts = {},
    keys = {
      { "<leader>mp", function()
        local peek = require("peek")
        if peek.is_open() then peek.close() else peek.open() end
      end, desc = "Markdown Preview" },
    },
  },
})
