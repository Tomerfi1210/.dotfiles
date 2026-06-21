vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

require("config.options")
require("config.autocmds")
require("config.database")
require("config.plugins")
require("config.ui")
require("config.keymaps")
require("config.completion")
require("config.treesitter")
require("config.lsp")
require("config.format")
require("config.search")
require("config.git")
require("config.editor")
require("config.diagnostics")
require("config.debug")
require("config.test")
require("config.tasks")
