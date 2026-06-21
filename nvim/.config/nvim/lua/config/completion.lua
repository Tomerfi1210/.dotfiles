require("luasnip").setup({})
require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 250,
			window = { border = "rounded" },
		},
		list = {
			selection = {
				preselect = false,
				auto_insert = false,
			},
		},
		menu = {
			border = "rounded",
			max_height = 12,
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			buffer = {
				min_keyword_length = 4,
				max_items = 5,
			},
		},
	},
	snippets = { preset = "luasnip" },
	fuzzy = { implementation = "lua" },
	signature = {
		enabled = true,
		window = {
			border = "rounded",
			show_documentation = false,
		},
	},
})
