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

M.copy_command = function()
  if vim.fn.has("wsl") == 1 then
    return "win32yank.exe -i --crlf"
  elseif vim.fn.has('macunix') then
    return "pbcopy"
  end
end

M.paste_command = function()
  if vim.fn.has("wsl") == 1 then
    return "win32yank.exe -o --lf"
  elseif vim.fn.has('macunix') then
    return "pbpaste"
  end
end

return M
