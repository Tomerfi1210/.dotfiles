local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local M = {}

local function with_opts(defaults, opts)
	return vim.tbl_deep_extend("force", defaults, opts or {})
end

local telescope_layout = {
	sorting_strategy = "ascending",
	layout_strategy = "horizontal",
	layout_config = {
		prompt_position = "top",
		width = 0.8,
		height = 0.75,
		horizontal = {
			preview_width = 0.5,
		},
	},
}

local function telescope_opts(opts)
	return with_opts(telescope_layout, opts)
end

function M.find_files(opts)
	builtin.find_files(telescope_opts(opts))
end

function M.live_grep(opts)
	builtin.live_grep(telescope_opts(opts))
end

function M.lsp_references()
	builtin.lsp_references(telescope_opts())
end

telescope.setup({
	defaults = with_opts(telescope_layout, {
		color_devicons = vim.g.have_nerd_font,
		prompt_prefix = "> ",
		selection_caret = "> ",
		mappings = {
			i = {
				["<C-j>"] = "move_selection_next",
				["<C-k>"] = "move_selection_previous",
			},
		},
	}),
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
	},
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "noice")

vim.keymap.set("n", "<leader>ff", M.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", M.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Buffers" })

vim.keymap.set("n", "<leader>sf", M.find_files, { desc = "Search files" })
vim.keymap.set("n", "<leader>sg", M.live_grep, { desc = "Search grep" })
vim.keymap.set("n", "<leader>sA", function()
	M.live_grep({
		additional_args = function()
			return { "--hidden", "--glob", "!.git/*" }
		end,
	})
end, { desc = "Search all files" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "Search recent files" })
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search help" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search commands" })

vim.keymap.set("n", "<leader>fn", function()
	M.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Neovim config files" })

vim.keymap.set("n", "<leader>sn", function()
	M.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search Neovim config files" })

vim.keymap.set("n", "<leader>/", function()
	builtin.current_buffer_fuzzy_find(themes.get_dropdown({
		previewer = false,
	}))
end, { desc = "Search current buffer" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user_telescope_lsp", { clear = true }),
	callback = function(event)
		local opts = function(desc)
			return { buffer = event.buf, desc = desc }
		end

		vim.keymap.set("n", "gI", builtin.lsp_implementations, opts("LSP implementations"))
		vim.keymap.set("n", "gy", builtin.lsp_type_definitions, opts("LSP type definitions"))
		vim.keymap.set("n", "gO", builtin.lsp_document_symbols, opts("Document symbols"))
		vim.keymap.set("n", "gW", builtin.lsp_dynamic_workspace_symbols, opts("Workspace symbols"))
	end,
})

return M
