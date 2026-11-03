local map = vim.keymap.set

-- Inside Herdr, move between Vim splits and fall back to moving Herdr focus
-- when there's no split in that direction.
local function herdr_move(wincmd, direction)
  return function()
    if vim.fn.winnr() ~= vim.fn.winnr(wincmd) then
      vim.cmd("wincmd " .. wincmd)
    else
      vim.fn.jobstart({ "herdr", "pane", "focus", "--current", "--direction", direction })
    end
  end
end

return function()
  if vim.env.HERDR_ENV == "1" then
    map("n", "<C-l>", herdr_move("l", "right"), { desc = "move to right herdr pane"})
    map("n", "<C-h>", herdr_move("h", "left"), { desc = "move to left herdr pane"})
    map("n", "<C-k>", herdr_move("k", "up"), { desc = "move to top herdr pane"})
    map("n", "<C-j>", herdr_move("j", "down"), { desc = "move to bottom herdr pane"})
    return
  end

  map("n", "<C-l>", function() require("tmux").move_right() end, { desc = "move to right tmux pane"})
  map("n", "<C-h>", function() require("tmux").move_left() end, { desc = "move to left tmux pane"})
  map("n", "<C-k>", function() require("tmux").move_top() end, { desc = "move to top tmux pane"})
  map("n", "<C-j>", function() require("tmux").move_bottom() end, { desc = "move to bottom tmux pane"})
end
