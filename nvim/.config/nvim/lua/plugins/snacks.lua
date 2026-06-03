return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sA",
        function()
          vim.ui.select({ "Root Dir", "cwd" }, { prompt = "Grep All" }, function(choice)
            if not choice then
              return
            end

            Snacks.picker.grep({
              cwd = choice == "Root Dir" and LazyVim.root() or nil,
              hidden = true,
              ignored = true,
            })
          end)
        end,
        desc = "Grep All (hidden/ignored)",
      },
    },
  },
}
