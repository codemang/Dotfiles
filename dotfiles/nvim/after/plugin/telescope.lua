vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', {})
vim.api.nvim_set_keymap('n', '<Leader>fl', ':Telescope live_grep<CR>', {})

local tb = require('telescope.builtin')

vim.keymap.set('n', '<Leader>fw', function()
  local word_under_cursor = vim.api.nvim_eval('expand("<cword>")')
	tb.live_grep({ default_text = word_under_cursor })
end)

-- https://github.com/nvim-telescope/telescope.nvim/issues/1923
function vim.getVisualSelection()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

vim.keymap.set('v', '<Leader>fv', function()
	local visually_selected_text = vim.getVisualSelection()
	tb.live_grep({ default_text = visually_selected_text })
end)
