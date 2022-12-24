local function load_light_colorscheme()
  vim.cmd "colorscheme edge"
  vim.o.background = "light"
end

local function load_dark_colorscheme()
  vim.g.sonokai_style = 'atlantis'
  vim.g.sonokai_better_performance = 1
  vim.cmd "colorscheme sonokai"
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function readlines(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines] = line
  end
  return lines
end

local function get_colorscheme()
  local filepath = vim.fn.expand('$HOME/.vim-colorscheme')

  if not file_exists(filepath) then
    return "light"
  end

  return readlines(filepath)[0]
end

local function load_colorscheme()
  local colorscheme = get_colorscheme()

  if not colorscheme or colorscheme == "light" then
    load_light_colorscheme()
  else
    load_dark_colorscheme()
  end
end

vim.api.nvim_create_user_command('LoadColorscheme', load_colorscheme, {})

