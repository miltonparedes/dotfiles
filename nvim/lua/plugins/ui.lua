return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Quitar el reloj de la sección derecha
      opts.sections.lualine_z = {}
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
          files = {
            hidden = true,
            ignored = false,
          },
        },
      },
    },
  },
}
