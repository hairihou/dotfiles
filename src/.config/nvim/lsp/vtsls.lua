local vue_language_server = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
return {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = vue_language_server,
            languages = { "vue" },
            configNamespace = "typescript",
          },
        },
      },
    },
  },
  root_markers = { "tsconfig.json", "package.json" },
}
