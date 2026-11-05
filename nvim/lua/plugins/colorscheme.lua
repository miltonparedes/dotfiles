-- On Omarchy the colorscheme comes from plugins/theme.lua (the current Omarchy
-- theme) and all-themes.lua keeps every theme plugin available for hot reload.
if require("omarchy").has_theme() then
  return {}
end

return {
  -- Disable unused colorschemes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },

  -- Gruvbox with the transparent background used by this setup
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      transparent_mode = true,
      italic = {
        comments = true,
      },
    },
  },

  -- Tell LazyVim to use Gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
