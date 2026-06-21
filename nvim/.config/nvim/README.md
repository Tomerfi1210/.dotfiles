# Native Neovim Config

Minimal Neovim 0.12 config using native `vim.pack`. No LazyVim, no `lazy.nvim`.

## What It Includes

- Go: `gopls`, `goimports`, `gofumpt`, `delve`, `nvim-dap-go`, `neotest-golang`
- Python: `basedpyright`, `ruff`, `debugpy`, `nvim-dap-python`, `neotest-python`
- Core editing/UI: Telescope, Treesitter, Blink completion, Conform formatting, Gitsigns, Oil, Overseer, Noice, Notify, mini.ai, mini.surround
- Debugging: `nvim-dap`, DAP UI, virtual text, F-key and `<leader>d` mappings

## Check

```sh
nvim --headless --clean -u NONE -l check-native-config.lua
XDG_CONFIG_HOME="$(dirname "$PWD")" \
XDG_DATA_HOME="${TMPDIR:-/tmp}/nvim-config-backup-data" \
XDG_STATE_HOME="${TMPDIR:-/tmp}/nvim-config-backup-state" \
XDG_CACHE_HOME="${TMPDIR:-/tmp}/nvim-config-backup-cache" \
NVIM_APPNAME="$(basename "$PWD")" \
nvim --headless +'lua print("startup ok")' +qa
```
