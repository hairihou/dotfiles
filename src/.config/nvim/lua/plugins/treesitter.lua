return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local ensure = {
      "angular", "bash", "css", "diff", "git_config", "gitcommit", "go", "gomod", "graphql",
      "html", "json", "lua", "luadoc", "markdown", "markdown_inline",
      "python", "query", "toml", "tsx", "typescript", "vim", "vimdoc", "vue", "yaml",
    }
    local installed = require("nvim-treesitter.config").get_installed()
    local todo = vim.tbl_filter(function(p)
      return not vim.tbl_contains(installed, p)
    end, ensure)
    if #todo > 0 then
      require("nvim-treesitter").install(todo)
    end
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("my.treesitter", {}),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if lang and vim.treesitter.language.add(lang) then
          vim.treesitter.start(ev.buf, lang)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
