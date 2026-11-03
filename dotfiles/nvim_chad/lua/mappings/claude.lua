local map = vim.keymap.set

return function()
  map("x", "<leader>cc", function()
    require("utils.claude_comment").comment()
  end, { desc = "Comment on selection and send to Claude (herdr)" })
  map("n", "<leader>cr", function()
    require("utils.claude_comment").reset_target()
  end, { desc = "Forget which Claude pane comments go to" })
end
