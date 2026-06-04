local git_ignored = setmetatable({}, {
  __index = function(self, dir)
    local result = vim
      .system(
        { "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
        { cwd = dir, text = true }
      )
      :wait()
    local ret = {}
    if result.code == 0 then
      for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
        ret[line:gsub("/$", "")] = true
      end
    end
    rawset(self, dir, ret)
    return ret
  end,
})

return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", "<cmd>Oil<cr>", desc = "File Explorer" },
  },
  lazy = false,
  opts = {
    keymaps = {
      ["-"] = "actions.parent",
      ["<CR>"] = "actions.select",
      ["<Esc>"] = "actions.close",
      ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
    view_options = {
      show_hidden = true,
      is_hidden_file = function(name, bufnr)
        if name == ".git" then
          return true
        end
        local dir = require("oil").get_current_dir(bufnr)
        if not dir then
          return vim.startswith(name, ".") and name ~= ".."
        end
        return git_ignored[dir][name] or false
      end,
    },
  },
}
