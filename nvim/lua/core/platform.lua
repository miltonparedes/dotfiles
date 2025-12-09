-- Platform detection and OS-specific settings
local M = {}

M.is_mac = vim.fn.has("macunix") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_mac
M.is_windows = vim.fn.has("win32") == 1
M.is_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil

function M.setup()
  -- macOS clipboard
  if M.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  elseif M.is_linux then
    if M.is_ssh then
      -- OSC52 for clipboard over SSH (works with modern terminals)
      vim.g.clipboard = {
        name = "OSC 52",
        copy = {
          ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
          ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
          ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
          ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
        },
      }
    elseif vim.env.WAYLAND_DISPLAY then
      -- Wayland clipboard
      vim.g.clipboard = {
        name = "wl-clipboard",
        copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
        paste = { ["+"] = "wl-paste", ["*"] = "wl-paste" },
        cache_enabled = 0,
      }
    end
    -- X11 uses xclip by default (Neovim handles this)
  end

  -- SSH-specific performance optimizations
  if M.is_ssh then
    vim.opt.updatetime = 500
    vim.opt.timeoutlen = 500
    vim.opt.ttyfast = true
  end
end

return M
