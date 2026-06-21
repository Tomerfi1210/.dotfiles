local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<C-s>", "<cmd>write ++p<CR>", { desc = "Save file" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

map("n", "<C-h>", "<C-w><C-h>", { desc = "Window left" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Window down" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Window up" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Window right" })

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })
map("n", "n", "nzzzv", { desc = "Next search centered" })
map("n", "N", "Nzzzv", { desc = "Previous search centered" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

map("x", "<leader>p", [[:_dP]], { desc = "Paste without yanking replaced text" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
