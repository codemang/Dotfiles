require "nvchad.options"

local general_utils = require("utils.general")

vim.opt.clipboard = 'unnamedplus'

-- In WSL use win32yank.exe so that copy/paste works between vim and host
-- machine.
vim.g.clipboard = {
  name = "copy/paste",
  copy = {
    ["+"] = general_utils.copy_command(),
    ["*"] = general_utils.copy_command(),
  },
  paste = {
    ["+"] = general_utils.paste_command(),
    ["*"] = general_utils.paste_command(),
  },
  cache_enabled = true,
}

-- Erase all extra spaces on save.
vim.cmd [[
  augroup RemoveTrailingLinesOnSave
    autocmd!
    " Remove trailing whitespaces on save.
    " https://howchoo.com/vim/vim-how-to-remove-trailing-whitespace-on-save
    autocmd BufWritePre * :%s/\s\+$//e
  augroup end
]]

-- If in a bloomberg folder use 4 spaces for tab, otherwise use 2.
vim.cmd [[
  augroup SetIndentBasedOnFolder
    autocmd!
    autocmd BufEnter */BB/**/* :set shiftwidth=4 tabstop=4 softtabstop=2
  augroup end
]]

-- Jump to last edit position on opening file
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  group = misc_augroup,
  pattern = '*',
  command = 'silent! normal! g`"zv'
})

vim.wo.wrap = false -- Don't wrap long lines.
vim.opt.number = true -- Show line numbers
vim.opt.scrolloff = 3 -- Always show at least 3 lines above/below the cursor
vim.opt.sidescrolloff = 15 -- Always show at least 3 characters to the right/left of the cursor

-- No swp files
vim.api.nvim_command('set noswapfile')
vim.api.nvim_command('set nobackup')
vim.api.nvim_command('set nowb')

-- Reselect visual block after indent/outdent.
vim.api.nvim_set_keymap('v', '<', '<gv', {})
vim.api.nvim_set_keymap('v', '>', '>gv', {})

-- Folding
vim.opt.foldenable = true -- Enable folding.
vim.opt.foldlevel = 0 -- Close all folds by default when you open the file.
vim.opt.foldmethod = 'marker' -- Folds are detected using a special marker.
vim.opt.foldmarker= '{{{,}}}' -- This is the marker used to determine fold start/end points.

-- Toggle spell check
vim.api.nvim_set_keymap('n', '<Leader>ss', ':setlocal spell! spelllang=en_us<CR>', {})

-- Enable spellcheck by default.
vim.opt.spelllang="en_us"
vim.opt.spell=true

-- Default tab width.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Set the snippet path.
vim.g.vscode_snippets_path={ require("utils.general").script_path() .. "snippets" }
