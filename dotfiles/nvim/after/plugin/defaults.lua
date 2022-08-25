
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
opt.clipboard = "unnamedplus" -- Access system clipboard

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true
opt.smarttab = true

-- No swp files
vim.api.nvim_command('set noswapfile')
vim.api.nvim_command('set nobackup')
vim.api.nvim_command('set nowb')

-- When using "y" to copy from Vim, copy to the global Clipboard used by
-- all apps. https://github.com/tmux/tmux/issues/543
opt.clipboard = 'unnamed'

api.nvim_set_keymap('n', '<Leader>w', ':w<Cr>', {})
api.nvim_set_keymap('n', '<Leader>wq', ':wq<Cr>', {})
api.nvim_set_keymap('n', '<Leader>e', ':e<Cr>', {})
api.nvim_set_keymap('n', '<Leader>e!', ':e!<Cr>', {})
api.nvim_set_keymap('n', '<Leader>q', ':q<Cr>', {})
api.nvim_set_keymap('n', '<Leader>q!', ':q!<Cr>', {})

