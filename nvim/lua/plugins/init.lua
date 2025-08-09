-- Plugin init.lua - aggregator that returns specs for lazy.setup()
-- This file collects all plugin configurations with error handling

local modules = {
  'plugins.colorscheme',
  'plugins.neo-tree',
  'plugins.lsp',
  'plugins.cmp',
  'plugins.treesitter',
  'plugins.telescope',
  'plugins.gitsigns',
  'plugins.ui',
}

local specs = {}
for _, m in ipairs(modules) do
  local ok, mod = pcall(require, m)
  if ok then
    vim.list_extend(specs, mod)
  end
end

return specs
