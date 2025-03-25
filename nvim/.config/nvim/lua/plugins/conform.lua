return {
  'stevearc/conform.nvim',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  config = function()
    local conform = require 'conform'
    conform.setup {
      formatters_by_ft = {
        javascript = { 'prettier' },
        json = { 'jq' },
        lua = { 'stylua' },
        python = { 'ruff_fix', 'ruff_format' },
        sql = { 'sqlfmt' },
        yaml = { 'prettier' },
      },
      formatters = {
        sqlfmt = {
          prepend_args = { '-l', '120' },
        },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return {
          lsp_fallback = true,
          timeout_ms = 500,
        }
      end,
    }

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat on save',
      bang = true,
    })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Enable autoformat on save',
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>mp', function()
      conform.format {
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      }
    end, { desc = '[M]ake [P]retty' })
    vim.keymap.set('n', '<leader>pe', '<cmd>FormatEnable<CR>', { desc = '[P]retty-on-save [E]nable' })
    vim.keymap.set('n', '<leader>pd', '<cmd>FormatDisable<CR>', { desc = '[P]retty-on-save [D]isable' })
  end,
}
