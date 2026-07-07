local function node_modules_paths(root_dir)
  local paths = {}
  local project = vim.fs.joinpath(root_dir, "node_modules")
  if vim.uv.fs_stat(project) then
    table.insert(paths, project)
  end
  local ngserver = vim.fn.exepath("ngserver")
  if ngserver ~= "" then
    local realpath = vim.uv.fs_realpath(ngserver) or ngserver
    local candidate = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(realpath), "../../.."))
    if vim.uv.fs_stat(candidate) then
      table.insert(paths, candidate)
    end
  end
  return paths
end

local function angular_core_version(root_dir)
  local package_json = vim.fs.joinpath(root_dir, "package.json")
  if not vim.uv.fs_stat(package_json) then
    return ""
  end
  local ok, content = pcall(vim.fn.readblob, package_json)
  if not ok or not content then
    return ""
  end
  local json = vim.json.decode(content) or {}
  local version = (json.dependencies or {})["@angular/core"] or (json.devDependencies or {})["@angular/core"] or ""
  return version:match("%d+%.%d+%.%d+") or ""
end

return {
  cmd = function(dispatchers, config)
    local root_dir = (config and config.root_dir) or vim.fn.getcwd()
    local node_paths = node_modules_paths(root_dir)
    local ng_probe = table.concat(
      vim
        .iter(node_paths)
        :map(function(p)
          return vim.fs.joinpath(p, "@angular/language-server/node_modules")
        end)
        :totable(),
      ","
    )
    return vim.lsp.rpc.start({
      "ngserver",
      "--stdio",
      "--tsProbeLocations",
      table.concat(node_paths, ","),
      "--ngProbeLocations",
      ng_probe,
      "--angularCoreVersion",
      angular_core_version(root_dir),
    }, dispatchers)
  end,
  filetypes = { "typescript", "html", "typescriptreact", "htmlangular" },
  root_markers = { "angular.json", "nx.json" },
}
