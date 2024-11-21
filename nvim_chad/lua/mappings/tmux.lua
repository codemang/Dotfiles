local map = vim.keymap.set

return function()
  map("n", "<C-l>", function() require("tmux").move_right() end, { desc = "move to right tmux pane"})
  map("n", "<C-h>", function() require("tmux").move_left() end, { desc = "move to left tmux pane"})
  map("n", "<C-k>", function() require("tmux").move_top() end, { desc = "move to top tmux pane"})
  map("n", "<C-j>", function() require("tmux").move_bottom() end, { desc = "move to bottom tmux pane"})
end
