return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux)" },
    { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Navigate down (tmux)" },
    { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Navigate up (tmux)" },
    { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Navigate right (tmux)" },
    { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Navigate to previous (tmux)" },
  },
}
