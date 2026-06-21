local function git_root()
	local path = vim.api.nvim_buf_get_name(0)
	path = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()

	local git_dir = vim.fs.find(".git", { path = path, upward = true })[1]
	return git_dir and vim.fs.dirname(git_dir) or vim.uv.cwd()
end

local function lazygit(cwd)
	if vim.fn.executable("lazygit") == 0 then
		vim.notify("lazygit not found", vim.log.levels.WARN)
		return
	end

	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.8)
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
	})

	vim.bo[buf].bufhidden = "wipe"
	vim.fn.termopen("lazygit", {
		cwd = cwd or vim.uv.cwd(),
		on_exit = function()
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end)
		end,
	})
	vim.cmd.startinsert()
end

vim.keymap.set("n", "<leader>gg", function()
	lazygit(git_root())
end, { desc = "Lazygit root dir" })

vim.keymap.set("n", "<leader>gG", function()
	lazygit(vim.uv.cwd())
end, { desc = "Lazygit cwd" })

require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "^" },
		changedelete = { text = "~" },
		untracked = { text = "+" },
	},
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 300,
	},
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "]h", function()
			gs.nav_hunk("next")
		end, "Next hunk")
		map("n", "[h", function()
			gs.nav_hunk("prev")
		end, "Previous hunk")
		map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
		map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, "Stage hunk")
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, "Reset hunk")
		map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
		map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
		map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
		map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk inline")
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, "Blame line")
		map("n", "<leader>uB", function()
			local enabled = gs.toggle_current_line_blame()
			vim.notify("Git blame line " .. (enabled and "enabled" or "disabled"))
		end, "Toggle git blame line")
		map("n", "<leader>uW", gs.toggle_word_diff, "Toggle git word diff")
	end,
})
