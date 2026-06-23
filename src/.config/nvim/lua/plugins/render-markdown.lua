return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>mp", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown Render" },
  },
  opts = {
    heading = {
      backgrounds = { "RenderMarkdownHBg" },
      foregrounds = { "RenderMarkdownH" },
    },
  },
}
