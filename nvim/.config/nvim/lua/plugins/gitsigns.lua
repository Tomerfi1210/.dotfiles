-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
  'lewis6991/gitsigns.nvim',
  keys = {
    { '<leader>gt', ':Gitsigns toggle_current_line_blame<CR>', desc = '[G]it [T]oggle blame' },
    { '<leader>gp', ':Gitsigns preview_hunk<CR>',              desc = '[G]it [P]review hunk' },
    { '<leader>gs', ':Gitsigns stage_hunk<CR>',                desc = '[G]it [S]tage hunk',  mode = { 'n', 'v' } },
    { '<leader>gr', ':Gitsigns reset_hunk<CR>',                desc = '[G]it [R]eset hunk',  mode = { 'n', 'v' } },
    { ']h',         ':Gitsigns next_hunk<CR>',                 desc = 'Next [H]unk',         mode = 'n' },
    { '[h',         ':Gitsigns prev_hunk<CR>',                 desc = 'Previous [H]unk',     mode = 'n' },
  },
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    signs_staged = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  },
}
