return {
  "stevearc/oil.nvim",
  keys = {
    { "<leader>e", "<cmd>Oil<cr>", desc = "File Explorer" },
  },
  lazy = false,
  opts = function()
    local last_dir, ignored = nil, {}
    local function is_git_ignored(name, bufnr)
      local dir = require("oil").get_current_dir(bufnr)
      if not dir then
        return false
      end
      if dir ~= last_dir then
        last_dir, ignored = dir, {}
        local out = vim.fn.systemlist({
          "git", "-C", dir, "ls-files", "--others", "--ignored", "--exclude-standard", "--directory",
        })
        if vim.v.shell_error == 0 then
          for _, p in ipairs(out) do
            ignored[(p:gsub("/$", ""))] = true
          end
        end
      end
      return ignored[name] == true
    end
    return {
      keymaps = {
        ["-"] = "actions.parent",
        ["<CR>"] = "actions.select",
        ["<Esc>"] = "actions.close",
      },
      use_default_keymaps = false,
      view_options = {
        is_hidden_file = function(name, _)
          return name == ".git" or name == ".DS_Store"
        end,
        highlight_filename = function(entry, _, _, _, bufnr)
          return is_git_ignored(entry.name, bufnr) and "Comment" or nil
        end,
      },
    }
  end,
}
