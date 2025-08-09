-- Neovim keymaps configuration
-- This file contains all the key mappings
-- VSCode-style mappings adapted for Neovim

-- Set leader key
vim.g.mapleader = " "

local keymap = vim.keymap

-- General keymaps
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- File explorer - Neo-tree (VSCode-style)
keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
keymap.set("n", "<C-b>", ":Neotree toggle<CR>", { desc = "Toggle sidebar" })

-- Buffer navigation (VSCode-style)
keymap.set("n", "<C-Tab>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<C-S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bb", ":Telescope buffers<CR>", { desc = "List buffers" })

-- Window navigation (VSCode-style)
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize window up" })
keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize window down" })
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Resize window left" })
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Resize window right" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Telescope (Quick Open VSCode-style)
keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Quick open files" })
keymap.set("n", "<C-S-p>", ":Telescope commands<CR>", { desc = "Command palette" })
keymap.set("n", "<C-S-f>", ":Telescope live_grep<CR>", { desc = "Search in files" })
keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })
keymap.set("n", "<leader>fr", ":Telescope oldfiles<CR>", { desc = "Recent files" })
keymap.set("n", "<leader>fc", ":Telescope grep_string<CR>", { desc = "Find string under cursor" })

-- LSP keymaps (VSCode-style)
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover information" })
keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })

-- Format document
keymap.set("n", "<leader>fm", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format document" })

-- Save and quit (VSCode-style)
keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<ESC>:w<CR>a", { desc = "Save file" })
keymap.set("n", "<C-q>", ":q<CR>", { desc = "Quit" })

-- Select all
keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Copy/paste (system clipboard)
keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })
keymap.set("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from clipboard" })

-- Undo/Redo
keymap.set("n", "<C-z>", "u", { desc = "Undo" })
keymap.set("n", "<C-y>", "<C-r>", { desc = "Redo" })

-- Line manipulation
keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Duplicate line
keymap.set("n", "<C-S-d>", "yyp", { desc = "Duplicate line" })
keymap.set("v", "<C-S-d>", "y'>p", { desc = "Duplicate selection" })

-- Comment toggle (requires comment plugin)
keymap.set("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
keymap.set("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })
