return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git Diff View" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File Git History" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Branch Git History" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_mixed" },
    },
    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 35 },
    },
  },
}
