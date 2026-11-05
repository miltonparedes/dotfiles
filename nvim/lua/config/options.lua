-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- LazyVim auto format
vim.g.autoformat = true

-- Spell checking for both English and Spanish
vim.opt.spelllang = { "en", "es" }

-- Clipboard: on Omarchy use its tmux/herdr/SSH-aware provider (copied from
-- Omarchy's config); elsewhere unnamedplus locally, OSC 52 over SSH.
if require("omarchy").present() then
  require("config.remote_clipboard").setup()
else
  require("config.clipboard").setup()
end
