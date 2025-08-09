-- Neovim options configuration
-- This file contains all the unified vim options and settings
-- Wrapped in a Lua module that sets options but returns nothing

local opt = vim.opt
local g = vim.g

-- Disable netrw (used by neo-tree)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true

-- Line wrapping
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line and column
opt.cursorline = true
opt.cursorcolumn = false

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.showmode = false
opt.conceallevel = 0

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- File handling
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.writebackup = false
opt.autowrite = true
opt.autoread = true

-- Window and scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 10
opt.cmdheight = 1
opt.winminwidth = 5
opt.winminheight = 1

-- Mouse and keyboard
opt.mouse = "a"
opt.timeoutlen = 300
opt.updatetime = 300

-- Completion
opt.completeopt = { "menuone", "noselect" }
opt.shortmess:append("c")

-- Whitespace and formatting
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Folding
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Status and command line
opt.laststatus = 3
opt.showcmd = true
opt.ruler = true

-- Spell checking
opt.spell = false
opt.spelllang = { "en" }

-- Session options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Format options
opt.formatoptions:remove({ "c", "r", "o" })

-- Python provider (disable if not needed)
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0
