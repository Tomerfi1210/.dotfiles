require("guess-indent").setup({})

require("oil").setup({
	default_file_explorer = true,
	columns = {
		{ "icon", default_file = "", directory = "", add_padding = true },
	},
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	view_options = {
		show_hidden = true,
		natural_order = true,
		is_always_hidden = function(name)
			return name == ".." or name == ".git"
		end,
	},
	float = {
		padding = 2,
		max_width = 90,
		max_height = 0,
	},
	win_options = {
		wrap = true,
		winblend = 0,
	},
	keymaps = {
		["<C-c>"] = false,
		q = "actions.close",
	},
})

vim.keymap.set("n", "<leader>O", "<cmd>Oil<CR>", { desc = "Oil file explorer" })

local ai = require("mini.ai")
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
	},
})
require("mini.surround").setup({})
