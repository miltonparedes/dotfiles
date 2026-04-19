-- Clipboard strategy:
--   * Local        -> let Neovim use the OS clipboard (pbcopy / xclip / wl-copy)
--   * SSH / remote -> use the builtin OSC 52 provider so yanks travel through
--                     the terminal back to the host clipboard (works through
--                     tmux + ssh as long as the terminal supports OSC 52).
-- Requires Neovim >= 0.10 for `vim.ui.clipboard.osc52` (we ship 0.12+).

local M = {}

local function is_remote()
  return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
end

function M.setup()
  -- Unify yank/paste with the system clipboard in every scenario.
  vim.opt.clipboard = "unnamedplus"

  if is_remote() then
    -- Force OSC 52 regardless of whether pbcopy/xclip exist on the remote host.
    local osc52 = require("vim.ui.clipboard.osc52")
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        -- OSC 52 paste is rarely supported by terminals; fall back to the
        -- last yanked text so `p` still does something sensible remotely.
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
      },
    }
  end
end

return M
