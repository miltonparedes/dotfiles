return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Quitar el reloj de la sección derecha
      opts.sections.lualine_z = {}
    end,
  },
}
