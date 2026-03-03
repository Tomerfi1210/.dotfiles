return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      -- Enhanced highlights for better contrast and DAP
      on_highlights = function(hl, c)
        -- Floating windows with subtle borders
        hl.FloatBorder = { fg = c.blue, bg = c.none }
        hl.NormalFloat = { bg = c.none }

        -- Better visual selection contrast
        hl.Visual = { bg = c.bg_visual, bold = true }
        hl.CursorLine = { bg = c.bg_highlight }

        -- Telescope
        hl.TelescopeBorder = { fg = c.blue, bg = c.none }
        hl.TelescopePromptBorder = { fg = c.orange, bg = c.none }
        hl.TelescopeResultsBorder = { fg = c.blue, bg = c.none }
        hl.TelescopePreviewBorder = { fg = c.blue, bg = c.none }

        -- DAP-specific highlights
        hl.DapBreakpoint = { fg = c.red1 }
        hl.DapBreakpointCondition = { fg = c.yellow }
        hl.DapLogPoint = { fg = c.blue }
        hl.DapStopped = { fg = c.green1 }
        hl.DapStoppedLine = { bg = c.bg_visual }

        -- DAP UI
        hl.DapUIScope = { fg = c.blue, bold = true }
        hl.DapUIType = { fg = c.purple }
        hl.DapUIValue = { fg = c.fg }
        hl.DapUIVariable = { fg = c.fg }
        hl.DapUIModifiedValue = { fg = c.orange, bold = true }
        hl.DapUIDecoration = { fg = c.blue }
        hl.DapUIThread = { fg = c.green }
        hl.DapUIStoppedThread = { fg = c.yellow }
        hl.DapUISource = { fg = c.purple }
        hl.DapUILineNumber = { fg = c.blue }
        hl.DapUIFloatBorder = { fg = c.blue }
        hl.DapUIWatchesEmpty = { fg = c.red1 }
        hl.DapUIWatchesValue = { fg = c.green }
        hl.DapUIWatchesError = { fg = c.red1 }
        hl.DapUIBreakpointsPath = { fg = c.blue }
        hl.DapUIBreakpointsInfo = { fg = c.green }
        hl.DapUIBreakpointsCurrentLine = { fg = c.green, bold = true }

        -- Which-key
        hl.WhichKeyBorder = { fg = c.blue, bg = c.none }

        -- Indent guides
        hl.IndentBlanklineChar = { fg = c.bg_highlight }
        hl.IblIndent = { fg = c.bg_highlight }
      end,
      -- Transparent statusline
      on_colors = function(colors)
        colors.bg_statusline = colors.none
      end,
    },
  },

  -- Configure LazyVim to load tokyonight
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
