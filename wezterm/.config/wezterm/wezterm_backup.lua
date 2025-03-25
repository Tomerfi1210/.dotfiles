local wezterm = require("wezterm")

local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Settings
local mux = wezterm.mux
wezterm.on("gui-startup", function()
	local _, _, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

local tmux = {}
if wezterm.target_triple == "aarch64-apple-darwin" then
	tmux = { "/opt/homebrew/bin/tmux", "new", "-As0" }
else
	tmux = { "tmux", "new", "-As0" }
end

config.default_prog = tmux
config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
	-- left = 0,
	-- right = 0,
	-- top = 0,
	bottom = 0,
}

config.color_scheme = "Tokyo Night"
-- config.color_scheme = "catppuccin-mocha" -- latte, frappe, macchiato, mocha
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", scale = 1.2, weight = "Medium" },
})

config.window_background_opacity = 0.8
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"
-- config.enable_scroll_bar = true

-- Dim inactive panes
config.inactive_pane_hsb = {
	saturation = 0.24,
	brightness = 0.5,
}

-- mouse
config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "",
	},
}

-- Keys
config.leader = { key = "d", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.ToggleFullScreen,
	},
	{ key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },

	-- { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	-- { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	-- { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	-- { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	-- { key = "h", mods = "CTRL", action = wezterm.action({ EmitEvent = "move-left" }) },
	-- { key = "l", mods = "CTRL", action = wezterm.action({ EmitEvent = "move-right" }) },
	-- { key = "j", mods = "CTRL", action = wezterm.action({ EmitEvent = "move-down" }) },
	-- { key = "k", mods = "CTRL", action = wezterm.action({ EmitEvent = "move-up" }) },

	{ key = "o", mods = "LEADER", action = act.ActivateCopyMode },
	-- { key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }),
	},

	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
	{ key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Renaming Tab Title...:" },
			}),
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "c",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter Workspace Name:" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	search_mode = {
		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
	},
}

config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

wezterm.on("update-status", function(window, pane)
	local stat = window:active_workspace()
	local stat_color = "#f7768e"
	if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	end
	if window:leader_is_active() then
		stat = "LDR"
		stat_color = "#bb9af7"
	end

	local basename = function(s)
		-- Nothing a little regex can't fix
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	-- Current working directory
	local cwd = pane:get_current_working_dir()
	if cwd then
		if type(cwd) == "userdata" then
			-- Wezterm introduced the URL object in 20240127-113634-bbcac864
			cwd = basename(cwd.file_path)
		else
			-- 20230712-072601-f4abf8fd or earlier version
			cwd = basename(cwd)
		end
	else
		cwd = ""
	end

	local cmd = pane:get_foreground_process_name()
	cmd = cmd and basename(cmd) or ""

	-- Left status (left of the tab line)
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		{ Text = " |" },
	}))

	-- Right status
	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
		{ Text = " | " },
		{ Foreground = { Color = "#e0af68" } },
		{ Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
		"ResetAttributes",
		{ Text = "  " },
	}))
end)

config.colors = {
	tab_bar = {
		background = "#4C4F64",
		active_tab = {
			bg_color = "#2E3440",
			fg_color = "#D8DEE9",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#4C4F64",
			fg_color = "#D8DEE9",
		},
		inactive_tab_hover = {
			bg_color = "#3B4252",
			fg_color = "#D8DEE9",
			intensity = "Bold",
		},
	},
}

return config
