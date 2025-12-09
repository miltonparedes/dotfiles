return {
  -- Disable the default tokyonight colorscheme
  { "folke/tokyonight.nvim", enabled = false },

  -- Mellifluous colorscheme with transparency
  {
    "ramojus/mellifluous.nvim",
    priority = 1000,
    config = function()
      require("mellifluous").setup({
        dim_inactive = false,
        color_set = "mellifluous",
        styles = {
          comments = { italic = true },
        },
        transparent_background = {
          enabled = true,
          floating_windows = true,
          telescope = true,
          file_tree = true,
          cursor_line = true,
          status_line = false,
        },
      })
      vim.cmd("colorscheme mellifluous")
    end,
  },

  -- Tell LazyVim to use mellifluous
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "mellifluous",
    },
  },
}
