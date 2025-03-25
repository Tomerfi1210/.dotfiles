return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>nm', ':Noice<CR>',        desc = '[N]oice [M]essages' },
    { '<leader>nd', ':NoiceDismiss<CR>', desc = '[N]oice [D]ismiss' },
  },
  config = function()
    require('noice').setup {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
    }
    require('notify').setup {
      background_colour = '#000000',
    }
  end,
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    'rcarriga/nvim-notify',
  },
}
