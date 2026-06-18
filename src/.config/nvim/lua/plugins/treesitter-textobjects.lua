return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })
    local select = require("nvim-treesitter-textobjects.select")
    local objects = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    }
    for key, query in pairs(objects) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query, "textobjects")
      end, { desc = "Select " .. query })
    end
    local move = require("nvim-treesitter-textobjects.move")
    local moves = {
      goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
      goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
    }
    for fn, maps in pairs(moves) do
      for key, query in pairs(maps) do
        vim.keymap.set({ "n", "x", "o" }, key, function()
          move[fn](query, "textobjects")
        end, { desc = fn .. " " .. query })
      end
    end
  end,
}
