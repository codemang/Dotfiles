local api = require('Comment.api')
local esc = vim.api.nvim_replace_termcodes(
  '<ESC>', true, false, true
)
function comment_visual_selection()
  vim.api.nvim_feedkeys(esc, 'nx', false)
  api.toggle.linewise(vim.fn.visualmode())
end

vim.keymap.set('n', '<Leader>c<space>', function()
  api.toggle.linewise.current()
end)

vim.keymap.set('v', '<Leader>c<space>', function()
  comment_visual_selection()
end)

vim.keymap.set('n', '<Leader>ca', function()
  api.insert.linewise.eol()
end)

vim.keymap.set('n', '<Leader>cy', function()
  vim.cmd('y')
  api.toggle.linewise.current()
end)

vim.keymap.set('v', '<Leader>cy', function()
  -- Copy visual selection to clipboard.
  vim.api.nvim_exec("call feedkeys('y')", true)

  -- Reselect the last visual selection, since yanking exits visual mode.
  vim.api.nvim_exec("call feedkeys('gv')", true)

  comment_visual_selection()

  -- Exit visual mode.
  vim.api.nvim_exec("call feedkeys('V')", true)
end)

vim.keymap.set('n', '<Leader>cO', function()
  api.insert.linewise.above()
end)

vim.keymap.set('n', '<Leader>co', function()
  api.insert.linewise.below()
end)

vim.keymap.set('n', '<Leader>cd', function()
  vim.api.nvim_exec("call feedkeys('V')", true)

  -- Copy visual selection to clipboard.
  vim.api.nvim_exec("call feedkeys('y')", true)

  -- Comment out the visual selection.
  comment_visual_selection()

  -- Paste the original code that was copied via yank.
  vim.api.nvim_exec("call feedkeys('p')", true)
end)

vim.keymap.set('v', '<Leader>cd', function()
  -- Copy visual selection to clipboard.
  vim.api.nvim_exec("call feedkeys('y')", true)

  -- Reselect the last visual selection, since yanking exits visual mode.
  vim.api.nvim_exec("call feedkeys('gv')", true)

  -- Comment out the visual selection.
  comment_visual_selection()

  -- Exit visual mode.
  vim.api.nvim_exec("call feedkeys('V')", true)

  -- Jump to the end of the last visual mode block.
  vim.api.nvim_exec("call feedkeys('`>')", true)

  -- Paste the original code that was copied via yank.
  vim.api.nvim_exec("call feedkeys('p')", true)
end)
