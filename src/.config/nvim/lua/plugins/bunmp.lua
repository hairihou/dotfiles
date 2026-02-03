return {
  "hairihou/bunmp",
  ft = "markdown",
  keys = {
    { "<leader>mp", function() require("bunmp").toggle() end, desc = "Markdown Preview" },
  },
}
