local M = {}

M.get_visual_selection = function()
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  text = string.gsub(text, "\n", "")

  if #text > 0 then
    return text
  else
    return ''
  end
end

M.script_path = function()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

return M
