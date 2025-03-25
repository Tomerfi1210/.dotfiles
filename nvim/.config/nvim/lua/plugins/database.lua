local function db_completion()
  require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
end

return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  keys = {
    { '<leader>db', vim.cmd.DBUIToggle, desc = 'Toggle [D]ata[B]ase' },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_save_location = vim.fn.stdpath 'config' .. require('plenary.path').path.sep .. 'db_ui'

    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'sql',
      },
      command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'sql',
      },
      command = 'setlocal commentstring=--\\ %s',
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'sql',
        'mysql',
        'plsql',
      },
      callback = function()
        vim.schedule(db_completion)
      end,
    })

    vim.keymap.set('v', '<leader>rq', '<Plug>(DBUI_ExecuteQuery)', { desc = '[R]un [Q]uery' })
  end,
}
