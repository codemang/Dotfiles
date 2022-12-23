local M = {}

function M.setup()
  require("scrollbar").setup({
    handlers = {
      cursor = false,
    }
  })
end

return M
