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

local function git_status_group(code)
  local x = code:sub(1, 1)
  local y = code:sub(2, 2)
  if x == "?" then
    return "OilGitCreated"
  elseif x == "U" or y == "U" or (x == "A" and y == "A") or (x == "D" and y == "D") then
    return "OilGitConflict"
  elseif x == "A" or x == "C" then
    return "OilGitCreated"
  elseif x == "R" then
    return "OilGitRenamed"
  elseif x == "D" or y == "D" then
    return "OilGitDeleted"
  elseif x == "M" or y == "M" or x == "T" or y == "T" then
    return "OilGitModified"
  end
end

local git_status = setmetatable({}, {
  __index = function(self, dir)
    local ret = {}
    local root = vim.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
    if root.code == 0 then
      local top_dir = vim.trim(root.stdout)
      local abs = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
      local prefix = abs == top_dir and "" or abs:sub(#top_dir + 2) .. "/"
      local result = vim.system({ "git", "-C", dir, "status", "--porcelain" }, { text = true }):wait()
      if result.code == 0 then
        for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
          local code = line:sub(1, 2)
          local path = line:sub(4):match("%->%s*(.+)$") or line:sub(4)
          if prefix == "" or vim.startswith(path, prefix) then
            local rel = path:sub(#prefix + 1)
            local top = rel:match("^([^/]+)")
            if top then
              ret[top] = ret[top] or (rel:find("/") and "OilGitModified" or git_status_group(code))
            end
          end
        end
      end
    end
    rawset(self, dir, ret)
    return ret
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("my.oil_git", {}),
  pattern = "oil://*",
  callback = function()
    for dir in pairs(git_status) do
      rawset(git_status, dir, nil)
    end
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
      highlight_filename = function(entry)
        local dir = require("oil").get_current_dir()
        if not dir then
          return nil
        end
        return git_status[dir][entry.name]
      end,
    },
  },
}
