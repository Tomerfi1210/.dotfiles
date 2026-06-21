local overseer = require("overseer")

overseer.setup({})

vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<CR>", { desc = "Run task" })
vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "Toggle tasks" })
vim.keymap.set("n", "<leader>ol", "<cmd>OverseerLoadBundle<CR>", { desc = "Load task bundle" })
vim.keymap.set("n", "<leader>oq", "<cmd>OverseerQuickAction<CR>", { desc = "Task quick action" })
vim.keymap.set("n", "<leader>oa", "<cmd>OverseerTaskAction<CR>", { desc = "Task action" })
vim.keymap.set("n", "<leader>ow", "<cmd>OverseerWatchRun<CR>", { desc = "Watch task" })
vim.keymap.set("n", "<leader>oc", "<cmd>OverseerClearCache<CR>", { desc = "Clear task cache" })
