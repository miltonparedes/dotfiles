-- Omarchy detection shared by the theme and clipboard setup.
-- On Omarchy, lua/plugins/theme.lua is a symlink (created by chezmoi, not
-- tracked in git) to the current Omarchy theme's neovim.lua.
local M = {}

M.theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

function M.present()
  return (vim.uv or vim.loop).fs_stat("/usr/share/omarchy") ~= nil
end

function M.has_theme()
  return (vim.uv or vim.loop).fs_stat(M.theme_file) ~= nil
end

return M
