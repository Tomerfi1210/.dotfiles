return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  keys = {
    { "<leader>cl", "<cmd>Leet<cr>", desc = "LeetCode" },
  },
  build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  dependencies = {
    -- include a picker of your choice, see picker section for more details
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lang = "golang",
    picker = { provider = "snacks-picker" },
    plugins = {
      non_standalone = true,
    },
  },
}
