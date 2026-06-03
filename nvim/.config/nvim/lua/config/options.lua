-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local cwd = vim.uv.cwd()
if not cwd or not vim.uv.fs_stat(cwd) then
  vim.cmd.cd(vim.fn.expand("~"))
end

vim.g.lazyvim_python_lsp = "basedpyright"
local opt = vim.opt
opt.wrap = true
opt.signcolumn = "yes:1"

-- Neovim 0.12: native popup menu styling
opt.pumborder = "rounded"
opt.pummaxwidth = 60

-- Neovim 0.12: global floating window border (matches DAP UI rounded style)
opt.winborder = "rounded"

-- Neovim 0.12: word-level inline diff highlighting
vim.opt.diffopt:append("inline:word")
