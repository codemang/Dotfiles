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
  elseif vim.fn.has('macunix') == 1 then
    return "pbcopy"
  elseif vim.fn.has('unix') == 1 then
    return "xclip -selection clipboard"
  end
end

M.paste_command = function()
  if vim.fn.has("wsl") == 1 then
    return "win32yank.exe -o --lf"
  elseif vim.fn.has('macunix') == 1 then
    return "pbpaste"
  elseif vim.fn.has('unix') == 1 then
    return "xclip -o -selection clipboard"
  end
end

return M
