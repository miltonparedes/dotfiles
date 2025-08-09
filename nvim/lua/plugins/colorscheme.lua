-- Colorscheme plugin configuration

return {
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      require("vscode").setup({
        -- Alternatively set style in setup
        style = "dark",
        
        -- Enable transparent background
        transparent = false,
        
        -- Enable italic comment
        italic_comments = true,
        
        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,
        
        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {},
        
        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {},
      })
      
      vim.cmd("colorscheme vscode")
    end,
  },
}
