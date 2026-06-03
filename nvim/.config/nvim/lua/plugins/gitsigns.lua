return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "<leader>ghP",
        function()
          require("gitsigns").preview_hunk()
        end,
        desc = "Preview Hunk",
      },
      {
        "<leader>ghi",
        function()
          require("gitsigns").preview_hunk_inline()
        end,
        desc = "Preview Hunk Inline",
      },
      {
        "<leader>ghx",
        function()
          require("gitsigns").toggle_deleted()
        end,
        desc = "Toggle Deleted Lines",
      },
      {
        "<leader>uW",
        function()
          require("gitsigns").toggle_word_diff()
        end,
        desc = "Toggle Git Word Diff",
      },
      {
        "<leader>uB",
        function()
          local enabled = require("gitsigns").toggle_current_line_blame()
          vim.notify("Git blame line " .. (enabled and "enabled" or "disabled"))
        end,
        desc = "Toggle Git Blame Line",
      },
    },
    opts = function(_, opts)
      opts.current_line_blame = true
      opts.current_line_blame_opts = vim.tbl_deep_extend("force", opts.current_line_blame_opts or {}, {
        delay = 300,
      })
    end,
  },
}
