return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Neovim 0.12: enable code lenses (virtual lines above functions)
      -- Use <leader>cc to run, <leader>cC to refresh (LazyVim defaults)
      codelens = {
        enabled = true,
      },
    },
  },
}
