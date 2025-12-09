-- Main Neovim configuration entry point
-- This file only requires the core modules as specified

require("core.options")
require("core.platform").setup()
require("core.keymaps")
require("core.lazy")
