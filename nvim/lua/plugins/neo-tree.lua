return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = { 'nvim-lua/plenary.nvim','nvim-tree/nvim-web-devicons','MunifTanjim/nui.nvim' },
    config = function()
      require('neo-tree').setup({
        window = { width = 30 },
        filesystem = { filtered_items = { hide_dotfiles = false } },
      })
    end,
  }
}
