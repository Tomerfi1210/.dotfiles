local go = require("config.languages.go")
local python = require("config.languages.python")
local search = require("config.search")

for _, key in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
	pcall(vim.keymap.del, "n", key)
end
pcall(vim.keymap.del, "x", "gra")

local function schemastore(kind, opts)
	local ok, store = pcall(require, "schemastore")
	if not ok then
		return {}
	end

	return store[kind].schemas(opts)
end

local function yaml_schemas()
	return vim.tbl_deep_extend("force", schemastore("yaml"), {
		kubernetes = {
			"k8s/**/*.yaml",
			"k8s/**/*.yml",
			"kubernetes/**/*.yaml",
			"kubernetes/**/*.yml",
		},
	})
end

local base_servers = {
	lua_ls = {
		settings = {
			Lua = {
				format = { enable = false },
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
				telemetry = { enable = false },
			},
		},
	},
	jsonls = {
		settings = {
			json = {
				schemas = schemastore("json"),
				validate = { enable = true },
			},
		},
	},
	yamlls = {
		filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
		capabilities = {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		},
		settings = {
			redhat = { telemetry = { enabled = false } },
			yaml = {
				completion = true,
				hover = true,
				keyOrdering = false,
				yamlVersion = "1.2",
				disableSchemaDetection = {
					"**/values.yaml",
					"**/values-*.yaml",
					"**/values_*.yaml",
					"**/values*.yaml",
				},
				format = { enable = false },
				validate = true,
				schemaStore = {
					enable = false,
					url = "",
				},
				schemas = yaml_schemas(),
			},
		},
	},
	helm_ls = {
		filetypes = { "helm", "yaml.helm-values" },
		root_markers = { "Chart.yaml" },
		settings = {
			["helm-ls"] = {
				valuesFiles = {
					mainValuesFile = "values.yaml",
					lintOverlayValuesFile = "values.lint.yaml",
					additionalValuesFilesGlobPattern = "values*.yaml",
				},
				yamlls = {
					enabled = true,
					enabledForFilesGlob = "*.{yaml,yml}",
					diagnosticsLimit = 50,
					showDiagnosticsDirectly = false,
					config = {
						completion = true,
						hover = true,
						schemas = {
							kubernetes = "templates/**",
						},
					},
				},
			},
		},
	},
	bashls = {},
	taplo = {},
	terraformls = {},
}

local servers = vim.tbl_deep_extend("force", {}, base_servers, go.servers, python.servers)

local ensure_installed = {
	"lua-language-server",
	"stylua",
	"json-lsp",
	"yaml-language-server",
	"helm-ls",
	"bash-language-server",
	"taplo",
	"terraform-ls",
	"prettierd",
	"shfmt",
}
vim.list_extend(ensure_installed, go.mason)
vim.list_extend(ensure_installed, python.mason)

require("mason").setup({})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
pcall(function()
	require("mason-lspconfig").setup({ automatic_enable = false })
end)

local lsp_attach_group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true })
local lsp_highlight_group = vim.api.nvim_create_augroup("user_lsp_highlight", { clear = true })
local lsp_detach_group = vim.api.nvim_create_augroup("user_lsp_detach", { clear = true })
local lsp_codelens_group = vim.api.nvim_create_augroup("user_lsp_codelens", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_attach_group,
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		if client.name == "ruff" then
			client.server_capabilities.hoverProvider = false
		end

		local map = function(keys, rhs, desc, mode, opts)
			opts = vim.tbl_extend("force", { buffer = event.buf, desc = "LSP: " .. desc }, opts or {})
			vim.keymap.set(mode or "n", keys, rhs, opts)
		end

		map("K", vim.lsp.buf.hover, "Hover")
		map("gd", vim.lsp.buf.definition, "Definition")
		map("gr", search.lsp_references, "References", nil, { nowait = true })
		map("gD", vim.lsp.buf.declaration, "Declaration")
		map("<leader>cr", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
		map("<leader>cl", vim.lsp.codelens.run, "Run code lens")
		map("<leader>cL", function()
			vim.lsp.codelens.enable(true, { bufnr = event.buf })
		end, "Refresh code lens")

		if client:supports_method("textDocument/documentHighlight", event.buf) then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = lsp_highlight_group,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = lsp_highlight_group,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = lsp_detach_group,
				buffer = event.buf,
				callback = function(detach_event)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = lsp_highlight_group, buffer = detach_event.buf })
				end,
			})
		end

		if client:supports_method("textDocument/inlayHint", event.buf) then
			map("<leader>uh", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
					{ bufnr = event.buf }
				)
			end, "Toggle inlay hints")
		end

		if client:supports_method("textDocument/codeLens", event.buf) then
			vim.lsp.codelens.enable(true, { bufnr = event.buf })
			vim.api.nvim_clear_autocmds({ group = lsp_codelens_group, buffer = event.buf })
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				buffer = event.buf,
				group = lsp_codelens_group,
				callback = function()
					vim.lsp.codelens.enable(true, { bufnr = event.buf })
				end,
			})
		end
	end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

for name, config in pairs(servers) do
	config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end
