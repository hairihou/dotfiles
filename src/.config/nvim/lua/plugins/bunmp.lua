return {
  "hairihou/bunmp",
  ft = "markdown",
  keys = {
    { "<leader>mp", function() require("bunmp").toggle() end, desc = "Markdown Preview" },
  },
  opts = {
    port = 1412,
    auto_open = true,
  },
}
