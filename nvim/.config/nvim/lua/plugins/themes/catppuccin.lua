return {
  'catppuccin/nvim',
  priority = 1000,
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup {
      flavour = 'frappe', -- latte, frappe, macchiato, mocha
      transparent_background = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = {
          enabled = true,
          indentscope_color = '',
        },
      },
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}
