local function gh(repo)
	return "https://github.com/" .. repo
end

local function run_build(name, cmd, cwd)
	vim.system(cmd, { cwd = cwd }, function(result)
		if result.code == 0 then
			return
		end

		local output = result.stderr ~= "" and result.stderr or result.stdout
		if output == "" then
			output = "No output from build command."
		end

		vim.schedule(function()
			vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
		end)
	end)
end

vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("user_pack_builds", { clear = true }),
	callback = function(event)
		local data = event.data or {}
		local spec = data.spec or {}
		local name = spec.name
		if not name and data.path then
			name = vim.fs.basename(data.path)
		end

		local kind = data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end

		if not name then
			return
		end

		if name == "telescope-fzf-native.nvim" and data.path and vim.fn.executable("make") == 1 then
			run_build(name, { "make" }, data.path)
			return
		end

		if name == "nvim-treesitter" then
			if not data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			pcall(vim.cmd.TSUpdate)
		end
	end,
})

local plugins = {
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-telescope/telescope.nvim"),
	gh("nvim-telescope/telescope-ui-select.nvim"),
	gh("lewis6991/gitsigns.nvim"),
	gh("folke/which-key.nvim"),
	gh("folke/tokyonight.nvim"),
	gh("j-hui/fidget.nvim"),
	gh("folke/noice.nvim"),
	gh("MunifTanjim/nui.nvim"),
	gh("rcarriga/nvim-notify"),
	gh("nvim-lualine/lualine.nvim"),
	gh("stevearc/oil.nvim"),
	gh("stevearc/overseer.nvim"),
	gh("nvim-mini/mini.nvim"),
	gh("b0o/SchemaStore.nvim"),
	gh("NMAC427/guess-indent.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	gh("stevearc/conform.nvim"),
	gh("rafamadriz/friendly-snippets"),
	gh("mfussenegger/nvim-dap"),
	gh("rcarriga/nvim-dap-ui"),
	gh("nvim-neotest/nvim-nio"),
	gh("theHamsta/nvim-dap-virtual-text"),
	gh("leoluz/nvim-dap-go"),
	gh("mfussenegger/nvim-dap-python"),
	gh("nvim-neotest/neotest"),
	gh("nvim-neotest/neotest-python"),
	gh("fredrikaverpil/neotest-golang"),
	gh("nvim-treesitter/nvim-treesitter-textobjects"),
	gh("tpope/vim-dadbod"),
	gh("kristijanhusak/vim-dadbod-ui"),
	gh("kristijanhusak/vim-dadbod-completion"),
	gh("christoomey/vim-tmux-navigator"),
	{ src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	gh("nvim-treesitter/nvim-treesitter"),
}

if vim.fn.executable("make") == 1 then
	table.insert(plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
end

if vim.g.have_nerd_font then
	table.insert(plugins, gh("nvim-tree/nvim-web-devicons"))
end

vim.pack.add(plugins)
