local neotest = require("neotest")

neotest.setup({
	adapters = {
		require("neotest-python")({
			runner = "pytest",
			python = function()
				return require("config.languages.python").python_path(vim.uv.cwd())
			end,
		}),
		require("neotest-golang")({}),
	},
})

vim.keymap.set("n", "<leader>tn", function()
	neotest.run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>td", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Debug nearest test" })

vim.keymap.set("n", "<leader>ts", function()
	neotest.summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
	neotest.output.open({ enter = true, auto_close = true })
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>tO", function()
	neotest.output_panel.toggle()
end, { desc = "Toggle test output panel" })

vim.keymap.set("n", "<leader>tS", function()
	neotest.run.stop()
end, { desc = "Stop tests" })
