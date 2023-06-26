local M = {}

M.comment_visual_selection = function()
  local api = require('Comment.api')
  local esc = vim.api.nvim_replace_termcodes(
    '<ESC>', true, false, true
  )
  vim.api.nvim_feedkeys(esc, 'nx', false)
  api.toggle.linewise(vim.fn.visualmode())
end

return M
