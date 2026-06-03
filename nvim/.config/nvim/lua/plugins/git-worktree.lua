local uv = vim.uv or vim.loop

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Git Worktree" })
end

local function run_git(args, cwd)
  local command = { "git" }
  if cwd and cwd ~= "" then
    vim.list_extend(command, { "-C", cwd })
  end
  vim.list_extend(command, args)

  local output = vim.fn.systemlist(command)
  if vim.v.shell_error ~= 0 then
    local err = table.concat(output, "\n")
    if err == "" then
      err = "git command failed: " .. table.concat(command, " ")
    end
    return nil, err
  end

  return output
end

local function get_repo_root()
  local output, err = run_git({ "rev-parse", "--show-toplevel" })
  if not output or not output[1] then
    return nil, err or "Not inside a git repository"
  end
  return output[1]
end

local function get_primary_root()
  local output, err = run_git({ "rev-parse", "--path-format=absolute", "--git-common-dir" })
  if not output or not output[1] then
    return nil, err or "Unable to resolve git common directory"
  end

  local common_dir = output[1]
  if common_dir:sub(-5) == "/.git" then
    return vim.fn.fnamemodify(common_dir, ":h")
  end

  return get_repo_root()
end

local function get_current_branch(root)
  local output = run_git({ "branch", "--show-current" }, root)
  if not output or not output[1] or output[1] == "" then
    return nil
  end
  return output[1]
end

local function is_absolute_path(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

local function is_ignored(root, entry)
  vim.fn.system({ "git", "-C", root, "check-ignore", "-q", entry })
  return vim.v.shell_error == 0
end

local function ensure_ignored_in_info_exclude(root, entry)
  if is_ignored(root, entry) then
    return true
  end

  local output, err = run_git({ "rev-parse", "--git-path", "info/exclude" }, root)
  if not output or not output[1] then
    return false, err or "Unable to locate .git/info/exclude"
  end

  local exclude_path = output[1]
  if not is_absolute_path(exclude_path) then
    exclude_path = root .. "/" .. exclude_path
  end

  local existing = ""
  local reader = io.open(exclude_path, "r")
  if reader then
    existing = reader:read("*a")
    reader:close()
  else
    local parent = vim.fn.fnamemodify(exclude_path, ":h")
    vim.fn.mkdir(parent, "p")
  end

  local expected = entry .. "/"
  for line in existing:gmatch("[^\r\n]+") do
    if line == expected or line == entry then
      return true
    end
  end

  local writer, open_err = io.open(exclude_path, "a")
  if not writer then
    return false, "Unable to update " .. exclude_path .. ": " .. tostring(open_err)
  end

  if existing ~= "" and existing:sub(-1) ~= "\n" then
    writer:write("\n")
  end
  writer:write(expected, "\n")
  writer:close()

  return true
end

local function preferred_worktree_parent(root)
  local hidden = root .. "/.worktrees"
  local visible = root .. "/worktrees"

  local hidden_stat = uv.fs_stat(hidden)
  if hidden_stat and hidden_stat.type == "directory" then
    return hidden, ".worktrees"
  end

  local visible_stat = uv.fs_stat(visible)
  if visible_stat and visible_stat.type == "directory" then
    return visible, "worktrees"
  end

  return hidden, ".worktrees"
end

local function parse_worktrees(lines)
  local worktrees = {}
  local current = {}

  local function flush()
    if current.path then
      if current.branch then
        current.branch = current.branch:gsub("^refs/heads/", "")
      elseif current.detached and current.head then
        current.branch = "detached@" .. current.head
      else
        current.branch = "(unknown)"
      end
      table.insert(worktrees, current)
    end
    current = {}
  end

  for _, line in ipairs(lines) do
    if line == "" then
      flush()
    elseif line:match("^worktree ") then
      current.path = line:sub(10)
    elseif line:match("^branch ") then
      current.branch = line:sub(8)
    elseif line:match("^HEAD ") then
      current.head = line:sub(6, 12)
    elseif line == "detached" then
      current.detached = true
    elseif line:match("^locked") then
      current.locked = true
    end
  end

  flush()

  local cwd = uv.cwd()
  local cwd_real = uv.fs_realpath(cwd) or cwd
  for _, wt in ipairs(worktrees) do
    local wt_real = uv.fs_realpath(wt.path) or wt.path
    wt.current = wt_real == cwd_real
  end

  table.sort(worktrees, function(a, b)
    if a.current ~= b.current then
      return a.current
    end
    return a.path < b.path
  end)

  return worktrees
end

local function list_worktrees(root)
  local output, err = run_git({ "worktree", "list", "--porcelain" }, root)
  if not output then
    return nil, err
  end
  return parse_worktrees(output)
end

local function format_worktree(item)
  local current = item.current and "* " or "  "
  local locked = item.locked and " [locked]" or ""
  return string.format("%s%s -> %s%s", current, item.branch, item.path, locked)
end

local function with_repo(callback)
  local root, err = get_repo_root()
  if not root then
    notify(err, vim.log.levels.ERROR)
    return
  end
  callback(root)
end

local function switch_worktree()
  with_repo(function(root)
    local worktrees, err = list_worktrees(root)
    if not worktrees then
      notify(err, vim.log.levels.ERROR)
      return
    end
    if #worktrees == 0 then
      notify("No worktrees found", vim.log.levels.WARN)
      return
    end

    vim.ui.select(worktrees, {
      prompt = "Switch to worktree",
      format_item = format_worktree,
    }, function(choice)
      if not choice or choice.current then
        return
      end
      require("git-worktree").switch_worktree(choice.path)
    end)
  end)
end

local function create_worktree()
  with_repo(function(root)
    local branch_hint = get_current_branch(root)
    local base_root, base_err = get_primary_root()
    if not base_root then
      notify(base_err, vim.log.levels.ERROR)
      return
    end

    vim.ui.input({
      prompt = "Worktree branch: ",
      default = branch_hint and (branch_hint .. "-wt") or "",
    }, function(branch)
      if not branch or branch == "" then
        return
      end

      local parent, folder_name = preferred_worktree_parent(base_root)
      local ok, err = ensure_ignored_in_info_exclude(base_root, folder_name)
      if not ok then
        notify(err, vim.log.levels.ERROR)
        return
      end

      local path = parent .. "/" .. branch
      vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

      require("git-worktree").create_worktree(path, branch, branch_hint)
    end)
  end)
end

local function delete_worktree()
  with_repo(function(root)
    local worktrees, err = list_worktrees(root)
    if not worktrees then
      notify(err, vim.log.levels.ERROR)
      return
    end

    local candidates = {}
    for _, wt in ipairs(worktrees) do
      if not wt.current then
        table.insert(candidates, wt)
      end
    end

    if #candidates == 0 then
      notify("Only the current worktree exists", vim.log.levels.WARN)
      return
    end

    vim.ui.select(candidates, {
      prompt = "Delete worktree",
      format_item = format_worktree,
    }, function(choice)
      if not choice then
        return
      end

      local confirm = vim.fn.confirm("Delete worktree?\n" .. choice.path, "&Yes\n&No", 2)
      if confirm ~= 1 then
        return
      end

      require("git-worktree").delete_worktree(choice.path, false, {
        on_success = function()
          vim.schedule(function()
            notify("Deleted worktree: " .. choice.path)
          end)
        end,
        on_failure = function()
          vim.schedule(function()
            notify("Failed to delete worktree: " .. choice.path, vim.log.levels.ERROR)
          end)
        end,
      })
    end)
  end)
end

local function show_worktrees()
  with_repo(function(root)
    local worktrees, err = list_worktrees(root)
    if not worktrees then
      notify(err, vim.log.levels.ERROR)
      return
    end
    if #worktrees == 0 then
      notify("No worktrees found", vim.log.levels.WARN)
      return
    end

    local lines = {}
    for _, wt in ipairs(worktrees) do
      table.insert(lines, format_worktree(wt))
    end

    notify(table.concat(lines, "\n"))
  end)
end

local function create_user_command(name, fn, desc)
  pcall(vim.api.nvim_del_user_command, name)
  vim.api.nvim_create_user_command(name, fn, { desc = desc })
end

local function register_commands()
  create_user_command("WorktreeSwitch", switch_worktree, "Switch git worktree")
  create_user_command("WorktreeCreate", create_worktree, "Create git worktree")
  create_user_command("WorktreeDelete", delete_worktree, "Delete git worktree")
  create_user_command("WorktreeList", show_worktrees, "List git worktrees")
end

local function register_hooks_once()
  if vim.g.git_worktree_hooks_registered then
    return
  end

  local hooks = require("git-worktree.hooks")
  local config = require("git-worktree.config")

  hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)
  hooks.register(hooks.type.DELETE, function()
    vim.cmd(config.update_on_change_command)
  end)

  vim.g.git_worktree_hooks_registered = true
end

return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  dependencies = { "nvim-lua/plenary.nvim" },
  init = function()
    vim.g.git_worktree = vim.tbl_deep_extend("force", vim.g.git_worktree or {}, {
      change_directory_command = "cd",
      update_on_change_command = "e .",
      clearjumps_on_change = true,
      autopush = false,
    })
  end,
  cmd = { "WorktreeSwitch", "WorktreeCreate", "WorktreeDelete", "WorktreeList" },
  keys = {
    { "<leader>gw", desc = "Worktrees" },
    { "<leader>gws", switch_worktree, desc = "Switch Worktree" },
    { "<leader>gwc", create_worktree, desc = "Create Worktree" },
    { "<leader>gwd", delete_worktree, desc = "Delete Worktree" },
    { "<leader>gwl", show_worktrees, desc = "List Worktrees" },
  },
  config = function()
    register_hooks_once()
    register_commands()
  end,
}
