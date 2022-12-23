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

-- https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming
function split_string(input_str, sep)
  if sep == nil then
    sep = "%s"
  end

  local t = {}

  for str in string.gmatch(input_str, "([^" .. sep .."]+)") do
    table.insert(t, str)
  end

  return t
end

-- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#first-picker
function choose_changed_files()
  local changed_git_files_str = io.popen("git diff --name-only"):read('*a')
  local changed_git_files_arr = split_string(changed_git_files_str)

  require('telescope.pickers').new({}, {
    prompt_title = "Changed Files",
    finder = require('telescope.finders').new_table {
      results = changed_git_files_arr
    },
    sorter = require('telescope.config').values.generic_sorter({}),
  }):find()
end

vim.api.nvim_set_keymap('n', '<Leader>fg', '<cmd>lua choose_changed_files()<CR>', {})
