local M = {}

function M.setup()
  -- Place the cursor in the commit popup when it's opened.
  vim.g.git_messenger_always_into_popup = true

  -- Show a decorative border.
  vim.cmd("let g:git_messenger_floating_win_opts = { 'border': 'rounded' }")
end

return M
