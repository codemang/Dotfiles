-- I'm not sure why, but calling the 'setup' function in the usual 'config'
-- directory did not work.
require('neoscroll').setup({
  easing = "quadratic",
})

local t = {}
local scrollTime = '100'

-- Syntax: t[keys] = {function, {function arguments}}
t['<C-u>'] = {'scroll', {'-vim.wo.scroll', 'true', scrollTime}}
t['<C-d>'] = {'scroll', { 'vim.wo.scroll', 'true', scrollTime}}
t['<C-b>'] = {'scroll', {'-vim.api.nvim_win_get_height(0)', 'true', scrollTime}}
t['<C-f>'] = {'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', scrollTime}}
t['<C-y>'] = {'scroll', {'-0.10', 'false', scrollTime}}
t['<C-e>'] = {'scroll', { '0.10', 'false', scrollTime}}
t['zt']    = {'zt', {scrollTime}}
t['zz']    = {'zz', {scrollTime}}
t['zb']    = {'zb', {scrollTime}}

-- https://github.com/karb94/neoscroll.nvim/issues/23#issuecomment-839630060
t['gg']    = {'scroll', {'-2*vim.api.nvim_buf_line_count(0)', 'true', '1', '5'}}
t['G']     = {'scroll', {'2*vim.api.nvim_buf_line_count(0)', 'true', '1', '5'}}

require('neoscroll.config').set_mappings(t)
