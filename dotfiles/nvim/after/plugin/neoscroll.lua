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

require('neoscroll.config').set_mappings(t)
