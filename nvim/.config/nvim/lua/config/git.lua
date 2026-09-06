local telescope_config = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local diffview_actions = require("diffview.actions")

local function git_output(args)
	local output = vim.fn.systemlist(args)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	return output
end

local function git_first_line(args)
	local output = git_output(args)
	return output and output[1] ~= "" and output[1] or nil
end

local function git_root()
	local path = vim.api.nvim_buf_get_name(0)
	path = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()

	return git_first_line({ "git", "-C", path, "rev-parse", "--show-toplevel" })
end

local function git_current_branch(root)
	return git_first_line({ "git", "-C", root, "branch", "--show-current" })
end

local function git_ref_exists(root, ref)
	return git_output({ "git", "-C", root, "show-ref", "--verify", "--quiet", ref }) ~= nil
end

local function git_default_ref(root, remote, branch)
	if git_ref_exists(root, "refs/heads/" .. branch) then
		return branch
	end

	return remote .. "/" .. branch
end

local function git_default_branch(root)
	local remotes = git_output({ "git", "-C", root, "remote" }) or {}
	if vim.tbl_contains(remotes, "origin") then
		remotes = vim.tbl_filter(function(remote)
			return remote ~= "origin"
		end, remotes)
		table.insert(remotes, 1, "origin")
	end

	for _, remote in ipairs(remotes) do
		local ref = git_first_line({ "git", "-C", root, "symbolic-ref", "--short", "refs/remotes/" .. remote .. "/HEAD" })
		if ref then
			return git_default_ref(root, remote, ref:sub(#remote + 2))
		end
	end

	for _, branch in ipairs({ "main", "master" }) do
		if git_ref_exists(root, "refs/heads/" .. branch) then
			return branch
		end
	end
end

local function git_remote_url(root)
	local remotes = git_output({ "git", "-C", root, "remote" }) or {}
	if vim.tbl_contains(remotes, "origin") then
		remotes = vim.tbl_filter(function(remote)
			return remote ~= "origin"
		end, remotes)
		table.insert(remotes, 1, "origin")
	end

	for _, remote in ipairs(remotes) do
		local url = git_first_line({ "git", "-C", root, "config", "--get", "remote." .. remote .. ".url" })
		if url then
			return url
		end
	end
end

local function web_repository_url(remote)
	local host, path = remote:match("^https?://[^@/]+@([^/]+)/(.+)$")
	if not host then
		host, path = remote:match("^https?://([^/]+)/(.+)$")
	end
	if not host then
		host, path = remote:match("^ssh://[^@/]+@([^/:]+):%d+/(.+)$")
	end
	if not host then
		host, path = remote:match("^ssh://[^@/]+@([^/]+)/(.+)$")
	end
	if not host then
		host, path = remote:match("^git@([^:]+):(.+)$")
	end

	if not host or (host ~= "github.com" and host ~= "gitlab.com") then
		return nil
	end

	path = path:gsub("/$", ""):gsub("%.git$", "")
	return path ~= "" and "https://" .. host .. "/" .. path or nil
end

local function url_escape(value)
	return (value:gsub("[^%w%-%._~/]", function(char)
		return ("%%%02X"):format(char:byte())
	end))
end

local function git_open_current_file()
	local file = vim.api.nvim_buf_get_name(0)
	local root = git_root()
	if file == "" or not root then
		vim.notify("Current buffer is not in a git repository", vim.log.levels.ERROR)
		return
	end

	local remote = git_remote_url(root)
	if not remote then
		vim.notify("No git remote found", vim.log.levels.ERROR)
		return
	end

	local repository = web_repository_url(remote)
	if not repository then
		vim.notify("Unsupported git remote: " .. remote, vim.log.levels.ERROR)
		return
	end

	local relative = vim.fs.relpath(root, file)
	if not relative then
		vim.notify("Could not determine file path relative to git root", vim.log.levels.ERROR)
		return
	end

	if vim.fn.has("mac") ~= 1 or vim.fn.executable("open") ~= 1 then
		vim.notify("macOS browser command 'open' is unavailable", vim.log.levels.ERROR)
		return
	end

	local branch = git_current_branch(root) or "HEAD"
	local url = ("%s/blob/%s/%s#L%d"):format(repository, url_escape(branch), url_escape(relative), vim.fn.line("."))
	vim.system({ "open", url }, { detach = true }, function(result)
		if result.code ~= 0 then
			vim.schedule(function()
				vim.notify("Could not open git URL in browser", vim.log.levels.ERROR)
			end)
		end
	end)
end

local function git_diff_default_branch()
	local root = git_root()
	if not root then
		vim.notify("Not in a git repository", vim.log.levels.ERROR)
		return
	end

	local default_branch = git_default_branch(root)
	if not default_branch then
		vim.notify("Could not resolve git default branch", vim.log.levels.ERROR)
		return
	end

	local current_branch = git_current_branch(root)
	local range = current_branch == default_branch and "HEAD" or default_branch .. "...HEAD"
	local opts = { cwd = root }

	pickers
		.new(opts, {
			prompt_title = "Git diff " .. range,
			finder = finders.new_oneshot_job({ "git", "-C", root, "diff", "--name-only", range, "--" }, {
				entry_maker = function(file)
					return {
						value = file,
						display = file,
						ordinal = file,
						path = root .. "/" .. file,
					}
				end,
			}),
			previewer = previewers.new_buffer_previewer({
				title = "Git diff",
				define_preview = function(self, entry)
					local diff = git_output({ "git", "-C", root, "--no-pager", "diff", range, "--", entry.value })
					if not diff or vim.tbl_isempty(diff) then
						diff = { "No diff for " .. entry.value }
					end

					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, diff)
					vim.bo[self.state.bufnr].filetype = "diff"
				end,
			}),
			sorter = telescope_config.file_sorter(opts),
		})
		:find()
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

local function git_line_history()
	local line = vim.fn.line(".")
	vim.cmd(("%d,%dDiffviewFileHistory"):format(line, line))
end

require("diffview").setup({
	enhanced_diff_hl = true,
	view = {
		default = { layout = "diff2_horizontal" },
		merge_tool = { layout = "diff3_mixed" },
		file_history = { layout = "diff2_horizontal" },
	},
	file_panel = {
		listing_style = "tree",
		win_config = { position = "left", width = 35 },
	},
	keymaps = {
		view = {
			{ "n", "<leader>ca", false },
			{ "n", "<leader>cM", diffview_actions.conflict_choose("all"), { desc = "Choose all conflict versions" } },
		},
		file_panel = {
			{ "n", "<leader>e", false },
			{ "n", "<leader>ge", diffview_actions.focus_files, { desc = "Focus Git files" } },
		},
		file_history_panel = {
			{ "n", "<leader>e", false },
			{ "n", "<leader>ge", diffview_actions.focus_files, { desc = "Focus Git files" } },
		},
	},
})

vim.keymap.set("n", "<leader>gg", function()
	lazygit(git_root())
end, { desc = "Lazygit root dir" })

vim.keymap.set("n", "<leader>gG", function()
	lazygit(vim.uv.cwd())
end, { desc = "Lazygit cwd" })

vim.keymap.set("n", "<leader>gD", git_diff_default_branch, { desc = "Git diff default branch" })
vim.keymap.set("n", "<leader>go", git_open_current_file, { desc = "Open file in git browser" })
vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<CR>", { desc = "Git diff view" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "Git file history" })
vim.keymap.set("n", "<leader>gl", git_line_history, { desc = "Git line history" })
vim.keymap.set("v", "<leader>gl", ":DiffviewFileHistory<CR>", { desc = "Git selection history" })

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
