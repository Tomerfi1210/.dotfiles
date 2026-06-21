local group = vim.api.nvim_create_augroup("user_config", { clear = true })

local function helm_chart_filetype(path, filetype)
	if path == "" then
		return nil
	end

	local dir = vim.fs.dirname(vim.fs.normalize(path))
	if not dir then
		return nil
	end

	local chart = vim.fs.find("Chart.yaml", { path = dir, upward = true, type = "file" })[1]
	if chart then
		return filetype
	end
end

vim.filetype.add({
	pattern = {
		[".*/templates/.*%.ya?ml"] = function(path)
			return helm_chart_filetype(path, "helm")
		end,
		[".*/templates/.*%.tpl"] = function(path)
			return helm_chart_filetype(path, "helm")
		end,
		[".*/templates/NOTES%.txt"] = function(path)
			return helm_chart_filetype(path, "helm")
		end,
		[".*/values.*%.ya?ml"] = function(path)
			return helm_chart_filetype(path, "yaml.helm-values")
		end,
	},
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	desc = "Highlight yanked text",
	callback = function()
		local ok = pcall(vim.hl.on_yank)
		if not ok and vim.highlight then
			vim.highlight.on_yank()
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	desc = "Restore cursor to last edit position",
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = group,
	desc = "Create parent directories before writing files",
	callback = function(args)
		if args.file:match("^%w%w+://") then
			return
		end

		local dir = vim.fn.fnamemodify(args.file, ":p:h")
		if dir ~= "" then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Use two-space indentation for common config formats",
	pattern = { "lua", "json", "yaml", "yaml.helm-values", "helm", "toml", "terraform", "hcl", "markdown" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Use four-space indentation for Python",
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.tabstop = 4
	end,
})
