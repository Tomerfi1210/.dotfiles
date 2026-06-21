local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.laststatus = 3
opt.updatetime = 250
opt.timeoutlen = 1000
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = { tab = "  ", nbsp = "+" }
opt.fillchars:append({ eob = " " })
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.confirm = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.pumheight = 12
opt.completeopt = { "menu", "menuone", "noinsert", "popup" }

pcall(function()
	opt.winborder = "rounded"
end)

pcall(function()
	opt.pumborder = "rounded"
	opt.pummaxwidth = 80
end)

pcall(function()
	opt.diffopt:append("inline:word")
end)

vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
	update_in_insert = false,
	severity_sort = true,
	underline = true,
	virtual_text = {
		spacing = 2,
		source = "if_many",
	},
	virtual_lines = false,
	float = {
		border = "rounded",
		source = "if_many",
	},
	jump = {
		on_jump = function(_, bufnr)
			vim.diagnostic.open_float({
				bufnr = bufnr,
				scope = "cursor",
				focus = false,
			})
		end,
	},
})
