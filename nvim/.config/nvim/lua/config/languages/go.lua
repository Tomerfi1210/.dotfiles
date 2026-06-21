return {
	mason = {
		"gopls",
		"goimports",
		"gofumpt",
		"delve",
	},
	servers = {
		gopls = {
			settings = {
				gopls = {
					gofumpt = true,
					completeFunctionCalls = true,
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					analyses = {
						fieldalignment = false,
						nilness = true,
						shadow = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					codelenses = {
						gc_details = true,
						generate = true,
						regenerate_cgo = true,
						run_govulncheck = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		},
	},
	formatters_by_ft = {
		go = { "goimports", "gofumpt" },
	},
}
