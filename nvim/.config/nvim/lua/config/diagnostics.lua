vim.keymap.set("n", "<leader>xx", function()
	vim.diagnostic.setqflist({ open = true })
end, { desc = "Diagnostics quickfix" })

vim.keymap.set("n", "<leader>xX", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Buffer diagnostics location list" })

vim.keymap.set("n", "<leader>xL", "<cmd>lopen<CR>", { desc = "Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>copen<CR>", { desc = "Quickfix list" })
