-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Tmux session picker
map("n", "<C-f>", "<cmd>silent !tmux neww ~/.local/scripts/session.sh<CR>", { desc = "Tmux Session Picker" })

-- Buffer management
map("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close Buffer" })

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })

-- Keep cursor centered on scroll/search
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down (Centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up (Centered)" })
map("n", "n", "nzzzv", { desc = "Next Search (Centered)" })
map("n", "N", "Nzzzv", { desc = "Prev Search (Centered)" })

-- Terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

-- Better paste in visual mode (don't yank replaced text)
map("x", "<leader>p", [["_dP]], { desc = "Paste Without Yank" })

-- Quick save (++p auto-creates parent directories, neovim 0.12)
map("n", "<C-s>", "<cmd>w ++p<CR>", { desc = "Save File" })

-- DAP breakpoint toggle -- map every possible F9 keycode for Ghostty compatibility
-- Ghostty may send F9 as <F9>, <F21>, or a CSI u sequence depending on config
for _, key in ipairs({ "<F9>", "<F21>", "<F33>" }) do
  map("n", key, function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
end

-- Built-in undo tree visualizer (neovim 0.12)
map("n", "<leader>uu", "<cmd>Undotree<CR>", { desc = "Undo Tree" })
