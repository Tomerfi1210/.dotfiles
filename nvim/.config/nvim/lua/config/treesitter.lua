local treesitter = require("nvim-treesitter")

local function attach(buf, language)
	if not vim.treesitter.language.add(language) then
		return
	end

	vim.treesitter.start(buf, language)

	if vim.treesitter.query.get(language, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

local available = treesitter.get_available()

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
	callback = function(args)
		local language = vim.treesitter.language.get_lang(args.match)
		if not language then
			return
		end

		local installed = treesitter.get_installed("parsers")
		if vim.tbl_contains(installed, language) then
			attach(args.buf, language)
			return
		end

		if vim.tbl_contains(available, language) then
			treesitter.install(language):await(function()
				attach(args.buf, language)
			end)
			return
		end

		attach(args.buf, language)
	end,
})
