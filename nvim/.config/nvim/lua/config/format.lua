local go = require("config.languages.go")
local python = require("config.languages.python")

local formatters_by_ft = vim.tbl_deep_extend("force", {
	lua = { "stylua" },
	json = { "prettierd", "prettier", stop_after_first = true },
	jsonc = { "prettierd", "prettier", stop_after_first = true },
	yaml = { "prettierd", "prettier", stop_after_first = true },
	markdown = { "prettierd", "prettier", stop_after_first = true },
	sh = { "shfmt" },
	bash = { "shfmt" },
	zsh = { "shfmt" },
	toml = { "taplo" },
	terraform = { "terraform_fmt" },
	hcl = { "terraform_fmt" },
}, go.formatters_by_ft, python.formatters_by_ft)

require("conform").setup({
	notify_on_error = false,
	default_format_opts = {
		lsp_format = "fallback",
	},
	formatters_by_ft = formatters_by_ft,
	format_on_save = function(bufnr)
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return nil
		end

		if not formatters_by_ft[vim.bo[bufnr].filetype] then
			return nil
		end

		return {
			timeout_ms = 1000,
			lsp_format = "fallback",
		}
	end,
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>uf", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	vim.notify("Autoformat " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for buffer")
end, { desc = "Toggle buffer autoformat" })
