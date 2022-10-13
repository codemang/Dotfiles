
local api = vim.api
local g = vim.g
local opt = vim.opt

-- Remap leader and local leader to <Space>
api.nvim_set_keymap("", ",", "<Nop>", { noremap = true, silent = true })
g.mapleader = ","
g.maplocalleader = ","

api.nvim_set_keymap('i', 'kj', '<Esc>', {})

opt.termguicolors = true -- Enable colors in terminal
opt.hlsearch = true --Set highlight on search
opt.number = true --Make line numbers default
opt.mouse = "a" --Enable mouse mode
opt.breakindent = true --Enable break indent
opt.undofile = true --Save undo history
opt.ignorecase = true --Case insensitive searching unless /C or capital in search
opt.smartcase = true -- Smart case
opt.updatetime = 250 --Decrease update time
opt.signcolumn = "yes" -- Always show sign column

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true
opt.smarttab = true

vim.wo.wrap = false -- Don't wrap long lines.
opt.number = true -- Show line numbers
opt.scrolloff = 3 -- Always show at least 3 lines above/below the cursor
opt.sidescrolloff = 15 -- Always show at least 3 characters to the right/left of the cursor

-- Folding
opt.foldenable = true -- Enable folding.
opt.foldlevel = 0 -- Close all folds by default when you open the file.
opt.foldmethod = 'marker' -- Folds are detected using a special marker.
opt.foldmarker= '{{{,}}}' -- This is the marker used to determine fold start/end points.

-- When using "y" to copy from Vim, copy to the global Clipboard used by
-- all apps. https://github.com/tmux/tmux/issues/543
opt.clipboard = 'unnamedplus'


-- No swp files
vim.api.nvim_command('set noswapfile')
vim.api.nvim_command('set nobackup')
vim.api.nvim_command('set nowb')

-- Open all folds.
api.nvim_set_keymap('n', 'zO', 'zR<CR>', {})

-- Close all folds.
api.nvim_set_keymap('n', 'zC', 'zM<CR>', {})

-- Toggle the current fold. We add 'k' to the end of the statement because for some reason the cursor was moving down one line.
api.nvim_set_keymap('n', 'zt', 'za<CR>k', {})

-- Auto format with new lines in visual mode
api.nvim_set_keymap('v', 'Q', 'gq', {})

-- Basic save/open/quit operations
api.nvim_set_keymap('n', '<Leader>w', ':w<Cr>', {})
api.nvim_set_keymap('n', '<Leader>wq', ':wq<Cr>', {})
api.nvim_set_keymap('n', '<Leader>e', ':e<Cr>', {})
api.nvim_set_keymap('n', '<Leader>.e', ':e!<Cr>', {})
api.nvim_set_keymap('n', '<Leader>q', ':q<Cr>', {})
api.nvim_set_keymap('n', '<Leader>.q', ':q!<Cr>', {})

-- Packer helpers.
api.nvim_set_keymap('n', '<Leader>ps', ':PackerSync<Cr>', {})
api.nvim_set_keymap('n', '<Leader>pc', ':PackerClean<Cr>', {})
api.nvim_set_keymap('n', '<Leader>s', ':luafile %<Cr>', {})

-- Reselect visual block after indent/outdent.
api.nvim_set_keymap('v', '<', '<gv', {})
api.nvim_set_keymap('v', '>', '>gv', {})

-- Toggle to the last used buffer.
api.nvim_set_keymap('n', '<Leader>j', ':e #<CR>', {})

-- Remove highlighting
api.nvim_set_keymap('n', '<Leader>hh', ':noh<CR>', {})

-- Toggle spell check
api.nvim_set_keymap('n', '<Leader>ss', ':setlocal spell! spelllang=en_us<CR>', {})

  -- Search for text in visual block
api.nvim_set_keymap('v', '*', 'y/<C-R>"<CR>N', {})

-- Add a line below/above and stay in normal mode -
api.nvim_set_keymap('n', '<Space>]', 'Okj', {})
api.nvim_set_keymap('n', '<Space>[', 'okj', {})

vim.cmd [[
  augroup RemoveTrailingLinesOnSave
    autocmd!
    " Remove trailing whitespaces on save.
    " https://howchoo.com/vim/vim-how-to-remove-trailing-whitespace-on-save
    autocmd BufWritePre * :%s/\s\+$//e
  augroup end
]]

