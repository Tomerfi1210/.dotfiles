return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    -- Virtual text.
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = { virt_text_pos = 'eol' },
    },
    {
      'jbyuki/one-small-step-for-vimkind',
      keys = {
        {
          '<leader>dl',
          function()
            require('osv').launch { port = 8086 }
          end,
          desc = 'Launch Lua adapter',
        },
      },
    },
    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'debugpy',
      },
    }

    vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

    -- Basic debugging keymaps, feel free to change to your liking!
    -- vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F5>', function()
      if vim.fn.filereadable '.vscode/launch.json' then
        require('dap.ext.vscode').load_launchjs()
      end
      require('dap').continue()
    end, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      -- icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      -- controls = {
      --   element = 'repl',
      --   enabled = true,
      --   icons = {
      --     pause = '⏸',
      --     play = '▶',
      --     step_into = '⏎',
      --     step_over = '⏭',
      --     step_out = '⏮',
      --     step_back = 'b',
      --     run_last = '▶▶',
      --     terminate = '⏹',
      --     disconnect = '⏏',
      --   },
      -- },
      -- layouts = {
      --   {
      --     elements = {
      --       { id = 'scopes', size = 0.5 },
      --       { id = 'watches', size = 0.5 },
      --     },
      --     size = 40,
      --     position = 'left',
      --   },
      --   {
      --     elements = { 'repl' },
      --     size = 10,
      --     position = 'bottom',
      --   },
      -- },
      -- mappings = {
      --   expand = { '<Tab>' },
      -- },
      -- layouts = {
      --   {
      --     elements = {
      --       { id = 'repl', size = 0.15 },
      --     },
      --     size = 0.35,
      --     position = 'bottom',
      --   },
      --   -- {
      --   -- 	elements = {
      --   -- 		{ id = "scopes", size = 0.25 },
      --   -- 	},
      --   -- 	size = 0.25,
      --   -- 	position = "right",
      --   -- },
      -- },
      -- render = {
      --   indent = 2,
      --   max_value_lines = 100,
      -- },
      layouts = {
        {
          elements = {
            { id = 'scopes',  size = 0.5 },
            { id = 'watches', size = 0.25 },
            { id = 'repl',    size = 0.25 },
          },
          size = 10,           -- Height of the bottom panel
          position = 'bottom', -- Always at the bottom
        },
      },
      mappings = {
        expand = { '<Tab>' },
      },
      render = {
        indent = 2,
        max_value_lines = 100,
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    -- vim.keymap.set('v', '<leader>ree', function()
    --   require('dap.ui.widgets').hover()
    -- end, { desc = 'Evaluate selection' })
    vim.keymap.set('v', '<leader>pre', function()
      require('dap').eval()
    end, { desc = 'Pre-Evaluate Expression' })
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })
    vim.keymap.set('n', '<leader>re', dapui.eval, { desc = '[R]un [E]val' })
    vim.keymap.set('n', '<leader>rk', dap.terminate, { desc = '[R]un [K]ill' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      -- delve = {
      -- dap_configurations = {
      --   {
      --     name = 'Devspace',
      --     type = 'go',
      --     request = 'launch',
      --     debugAdapter = 'dlv-dap',
      --     mode = 'exec',
      --     program = '/app/main',
      --     port = 23450,
      --     host = '127.0.0.1',
      --   },
      -- },
      -- },
    }
    require('dap-python').setup '/Users/tomerfisher/zesty/tomer/.venv/bin/python'
  end,
}
