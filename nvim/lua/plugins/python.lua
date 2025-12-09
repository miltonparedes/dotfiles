-- Python development plugins

return {
  -- Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    ft = "python",
    branch = "regexp",
    config = function()
      require("venv-selector").setup({
        name = { "venv", ".venv", "env", ".env" },
        auto_refresh = false,
      })
    end,
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
    },
  },
}
