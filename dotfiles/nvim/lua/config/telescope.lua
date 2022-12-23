local M = {}

function M.setup()
  local telescope = require "telescope"
  telescope.load_extension("live_grep_args")
end

return M
