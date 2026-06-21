require("tokyonight").setup({
	style = "moon",
	transparent = true,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "transparent",
		floats = "transparent",
	},
	on_highlights = function(hl, c)
		hl.FloatBorder = { fg = c.blue, bg = c.none }
		hl.NormalFloat = { bg = c.none }
		hl.Visual = { bg = c.bg_visual, bold = true }
		hl.CursorLine = { bg = c.bg_highlight }

		hl.TelescopeBorder = { fg = c.blue, bg = c.none }
		hl.TelescopePromptBorder = { fg = c.orange, bg = c.none }
		hl.TelescopeResultsBorder = { fg = c.blue, bg = c.none }
		hl.TelescopePreviewBorder = { fg = c.blue, bg = c.none }

		hl.DapBreakpoint = { fg = c.red1 }
		hl.DapBreakpointCondition = { fg = c.yellow }
		hl.DapLogPoint = { fg = c.blue }
		hl.DapStopped = { fg = c.green1 }
		hl.DapStoppedLine = { bg = c.bg_visual }
		hl.DapUIScope = { fg = c.blue, bold = true }
		hl.DapUIType = { fg = c.purple }
		hl.DapUIValue = { fg = c.fg }
		hl.DapUIVariable = { fg = c.fg }
		hl.DapUIModifiedValue = { fg = c.orange, bold = true }
		hl.DapUIDecoration = { fg = c.blue }
		hl.DapUIThread = { fg = c.green }
		hl.DapUIStoppedThread = { fg = c.yellow }
		hl.DapUISource = { fg = c.purple }
		hl.DapUILineNumber = { fg = c.blue }
		hl.DapUIFloatBorder = { fg = c.blue }
		hl.DapUIWatchesEmpty = { fg = c.red1 }
		hl.DapUIWatchesValue = { fg = c.green }
		hl.DapUIWatchesError = { fg = c.red1 }
		hl.DapUIBreakpointsPath = { fg = c.blue }
		hl.DapUIBreakpointsInfo = { fg = c.green }
		hl.DapUIBreakpointsCurrentLine = { fg = c.green, bold = true }

		hl.WhichKeyBorder = { fg = c.blue, bg = c.none }
		hl.PmenuBorder = { fg = c.blue, bg = c.none }
		hl.PmenuShadow = { bg = c.none }
		hl.PmenuShadowThrough = { bg = c.none }
	end,
	on_colors = function(colors)
		colors.bg_statusline = colors.none
	end,
})
vim.cmd.colorscheme("tokyonight-moon")

pcall(function()
	require("nvim-web-devicons").setup({ default = true })
end)

local notify = require("notify")
notify.setup({
	background_colour = "#000000",
	stages = "fade_in_slide_out",
	timeout = 3000,
})
vim.notify = notify

require("noice").setup({
	cmdline = {
		view = "cmdline_popup",
	},
	lsp = {
		progress = { enabled = false },
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},
})

local function dap_status()
	return "  " .. require("dap").status()
end

local function has_dap_status()
	return package.loaded.dap and require("dap").status() ~= ""
end

local function root_dir()
	local path = vim.api.nvim_buf_get_name(0)
	local start = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()
	local root = start
			and vim.fs.root(start, { ".git", "go.mod", "package.json", "pyproject.toml", "Cargo.toml", "Chart.yaml" })
		or vim.uv.cwd()

	return " " .. vim.fs.basename(root or start or vim.uv.cwd() or "~")
end

require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = vim.g.have_nerd_font,
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{ "branch", icon = "" },
		},
		lualine_c = {
			root_dir,
			{
				"diagnostics",
				symbols = {
					error = " ",
					warn = " ",
					info = " ",
					hint = " ",
				},
			},
			{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
			{
				"filename",
				path = 1,
				symbols = {
					modified = " [+]",
					readonly = " [-]",
					unnamed = "[No Name]",
				},
			},
		},
		lualine_x = {
			{
				dap_status,
				cond = has_dap_status,
			},
			{
				"diff",
				symbols = {
					added = " ",
					modified = " ",
					removed = " ",
				},
				source = function()
					local gitsigns = vim.b.gitsigns_status_dict
					if not gitsigns then
						return nil
					end

					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end,
			},
			{ "filetype", colored = true },
			{ "encoding" },
			{ "fileformat" },
		},
		lualine_y = {
			{ "progress", separator = " ", padding = { left = 1, right = 0 } },
			{ "location", padding = { left = 0, right = 1 } },
		},
		lualine_z = {
			function()
				return " " .. os.date("%R")
			end,
		},
	},
	extensions = { "quickfix", "man", "nvim-dap-ui", "oil" },
})

vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<CR>", { desc = "Noice history" })
vim.keymap.set("n", "<leader>nl", "<cmd>Noice last<CR>", { desc = "Noice last message" })
vim.keymap.set("n", "<leader>ne", "<cmd>Noice errors<CR>", { desc = "Noice errors" })
vim.keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<CR>", { desc = "Noice dismiss" })

require("which-key").setup({
	preset = "helix",
	delay = 300,
	icons = {
		mappings = vim.g.have_nerd_font,
		colors = true,
	},
	win = {
		no_overlap = false,
		width = { min = 30, max = 60 },
		height = { min = 4, max = 25 },
		col = -1,
		row = -1,
		border = "rounded",
		padding = { 0, 1 },
		title = true,
		title_pos = "left",
	},
	spec = {
		{ "<leader>c", group = "Code", mode = { "n", "x" } },
		{ "<leader>d", group = "Debug" },
		{ "<leader>f", group = "Find" },
		{ "<leader>g", group = "Git" },
		{ "<leader>h", group = "Hunk", mode = { "n", "x" } },
		{ "<leader>n", group = "Noice" },
		{ "<leader>o", group = "Overseer" },
		{ "<leader>s", group = "Search", mode = { "n", "x" } },
		{ "<leader>t", group = "Test" },
		{ "<leader>u", group = "Toggle" },
		{ "<leader>x", group = "Diagnostics" },
		{ "gr", group = "LSP" },
	},
})

require("fidget").setup({})
