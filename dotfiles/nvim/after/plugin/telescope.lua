local tb = require('telescope.builtin')
local lga_actions = require('telescope-live-grep-args.actions')

vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', {})
vim.api.nvim_set_keymap('n', '<Leader>fl', ':Telescope live_grep<CR>', {})

-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/14
live_grep_raw = function(opts, mode)
  opts = opts or {}
  if not opts.default_text then
    if mode then
      opts.default_text = '"' .. escape_rg_text(get_text(mode)) .. '"'
    else
      opts.default_text = '"'
    end
  end

  require('telescope').extensions.live_grep_args.live_grep_args(opts)
end

vim.keymap.set('n', '<Leader>fw', function()
  local word_under_cursor = vim.api.nvim_eval('expand("<cword>")')
  live_grep_raw({ default_text = '"' .. word_under_cursor .. '"' })
end)

-- https://github.com/nvim-telescope/telescope.nvim/issues/1923
function getVisualSelection()
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
	local visually_selected_text = getVisualSelection()
	live_grep_raw({ default_text = '"' .. visually_selected_text .. '"' })
end)
