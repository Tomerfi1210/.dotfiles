local wezterm = require 'wezterm'
local config = require 'config'
require 'events'

-- Apply color scheme based on the WEZTERM_THEME environment variable
local themes = {
  nord = 'Nord (Gogh)',
  onedark = 'One Dark (Gogh)',
  catpuchine = 'Catpuchine Mocha',
}
local success, stdout, stderr = wezterm.run_child_process { os.getenv 'SHELL', '-c', 'printenv WEZTERM_THEME' }
local selected_theme = stdout:gsub('%s+', '') -- Remove all whitespace characters including newline
-- config.color_scheme = themes[selected_theme]

if themes[selected_theme] then
  config.color_scheme = themes[selected_theme]
else
  config.color_scheme = 'Catpuchine Mocha'
end

config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = 'f',
    mods = 'LEADER',
    action = wezterm.action.ToggleFullScreen,
  },
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  { key = 'LeftArrow', mods = 'OPT', action = wezterm.action { SendString = '\x1bb' } },
  -- Make Option-Right equivalent to Alt-f; forward-word
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action { SendString = '\x1bf' } },
}

return config
