return {
  'Exafunction/codeium.vim',
  event = 'BufEnter',
  config = function()
    -- Disable automatic bindings
    vim.g.codeium_disable_bindings = 1
    -- vim.g.codeium_manual = true

    vim.keymap.set('i', '<C-g>', function()
      return vim.fn['codeium#Accept']()
    end, { expr = true, silent = true, desc = 'Codeium: Accept' })
  end,
}
