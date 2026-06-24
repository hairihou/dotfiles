return {
  "echasnovski/mini.surround",
  keys = {
    { "gsa", mode = { "n", "x" }, desc = "Add surrounding" },
    { "gsd", desc = "Delete surrounding" },
    { "gsr", desc = "Replace surrounding" },
    { "gsf", desc = "Find surrounding (right)" },
    { "gsF", desc = "Find surrounding (left)" },
    { "gsh", desc = "Highlight surrounding" },
    { "gsn", desc = "Update n_lines" },
  },
  opts = {
    mappings = {
      add = "gsa",
      delete = "gsd",
      replace = "gsr",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      update_n_lines = "gsn",
    },
  },
}
