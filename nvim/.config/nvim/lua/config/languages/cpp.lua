return {
	mason = {
		"clangd",
		"clang-format",
		"codelldb",
	},
	servers = {
		clangd = {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--function-arg-placeholders",
				"--fallback-style=llvm",
			},
		},
	},
	formatters_by_ft = {
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
}
