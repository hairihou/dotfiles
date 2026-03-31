return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>md", "<Cmd>RenderMarkdown toggle<CR>", desc = "Markdown Preview" },
  },
  opts = {
    heading = {
      backgrounds = { "RenderMarkdownHBg" },
      foregrounds = { "RenderMarkdownH" },
    },
  },
}
