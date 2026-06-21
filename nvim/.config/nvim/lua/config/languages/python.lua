local function python_path(root_dir)
	if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
		return vim.env.VIRTUAL_ENV .. "/bin/python"
	end

	if root_dir and root_dir ~= "" then
		for _, name in ipairs({ ".venv", "venv" }) do
			local candidate = root_dir .. "/" .. name .. "/bin/python"
			if vim.uv.fs_stat(candidate) then
				return candidate
			end
		end
	end

	local python3 = vim.fn.exepath("python3")
	if python3 ~= "" then
		return python3
	end

	local python = vim.fn.exepath("python")
	if python ~= "" then
		return python
	end

	return "python"
end

return {
	mason = {
		"basedpyright",
		"ruff",
		"debugpy",
	},
	servers = {
		basedpyright = {
			before_init = function(_, config)
				config.settings = config.settings or {}
				config.settings.python = config.settings.python or {}
				config.settings.python.pythonPath = python_path(config.root_dir)
			end,
			settings = {
				basedpyright = {
					analysis = {
						typeCheckingMode = "basic",
						autoImportCompletions = true,
						diagnosticSeverityOverrides = {
							reportUnusedImport = "information",
							reportUnusedFunction = "information",
							reportUnusedVariable = "information",
							reportGeneralTypeIssues = "none",
							reportOptionalMemberAccess = "none",
							reportOptionalSubscript = "none",
							reportPrivateImportUsage = "none",
						},
					},
				},
			},
		},
		ruff = {
			init_options = {
				settings = {
					logLevel = "error",
				},
			},
			on_attach = function(client)
				client.server_capabilities.hoverProvider = false
			end,
		},
	},
	formatters_by_ft = {
		python = { "ruff_organize_imports", "ruff_format" },
	},
	python_path = python_path,
}
