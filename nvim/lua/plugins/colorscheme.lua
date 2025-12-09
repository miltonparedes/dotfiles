-- Colorscheme plugin configuration

return {
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
          enabled = false,
          floating_windows = true,
          telescope = true,
          file_tree = true,
          cursor_line = true,
          status_line = false,
        },
        flat_background = {
          line_numbers = true,
          floating_windows = true,
          file_tree = true,
          cursor_line_number = true,
        },
      })

      vim.cmd("colorscheme mellifluous")
    end,
  },
}
