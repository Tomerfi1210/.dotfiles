return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.trigger = vim.tbl_deep_extend("force", opts.completion.trigger or {}, {
        show_on_keyword = true,
        show_on_trigger_character = true,
        show_on_backspace_in_keyword = false,
      })

      opts.completion.menu = vim.tbl_deep_extend("force", opts.completion.menu or {}, {
        border = "rounded",
        max_height = 12,
      })

      opts.completion.documentation = vim.tbl_deep_extend("force", opts.completion.documentation or {}, {
        auto_show = true,
        auto_show_delay_ms = 250,
        window = {
          border = "rounded",
        },
      })

      opts.completion.list = vim.tbl_deep_extend("force", opts.completion.list or {}, {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      })

      opts.sources = opts.sources or {}
      opts.sources.default = { "lsp", "path", "snippets", "buffer" }
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        lsp = {
          score_offset = 100,
        },
        buffer = {
          score_offset = -10,
          min_keyword_length = 4,
          max_items = 5,
        },
        path = {
          score_offset = 20,
        },
        snippets = {
          score_offset = 10,
        },
      })

      opts.keymap = vim.tbl_deep_extend("force", opts.keymap or {}, {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      })

      opts.signature = vim.tbl_deep_extend("force", opts.signature or {}, {
        enabled = true,
        window = {
          border = "rounded",
          show_documentation = false,
        },
      })
    end,
  },
}
