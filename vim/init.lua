-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

vim.g.mapleader = ","
vim.api.nvim_set_keymap("i", "kj", "<Esc>", {})

-- When using "y" to copy from Vim, copy to the global Clipboard used by
-- all apps. https://github.com/tmux/tmux/issues/543
vim.opt.clipboard = 'unnamedplus'

if os.getenv('WSL_INTEROP') then
  -- Enable copy/paste from windows clipboard.
  vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
          ["+"] = 'win32yank.exe -i --crlf',
          ['*'] = 'win32yank.exe -i --crlf',
        },
      paste = {
          ['+'] = 'win32yank.exe -o --lf',
          ['*'] = 'win32yank.exe -o --lf',
        },
      cache_enabled = 0,
  }
end

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
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.g.vscode_snippets_path={ "/home/nrubin19/dotfiles/nvchad_custom/snippets" }
