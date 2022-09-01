-- Move line under cursor down 1 line.
vim.api.nvim_set_keymap('n', '<Space>j', ':MoveLine(1)<CR>', { silent = true })

-- Move line under cursor up 1 line.
vim.api.nvim_set_keymap('n', '<Space>k', ':MoveLine(-1)<CR>', { silent = true })

-- Move visually selected block down 1 line. The moved block didn't always
-- have the right indentation, so adding '=' to format the block and 'gv' to
-- reselect the visual block.
vim.api.nvim_set_keymap('v', '<Space>j', ':MoveBlock(1)<CR>=gv', { silent = true })

-- Move visually selected block down 1 line. The moved block didn't always
-- have the right indentation, so adding '=' to format the block and 'gv' to
-- reselect the visual block.
vim.api.nvim_set_keymap('v', '<Space>k', ':MoveBlock(-1)<CR>=gv', { silent = true })
