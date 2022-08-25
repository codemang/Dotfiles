local M = {}

function M.setup()
  require'bufferline'.setup {
    auto_hide = true -- Hide the tab bar when there is only one buffer open.
  }
end

return M
