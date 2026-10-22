-- Keep the NvChad theme in sync with ~/.color-scheme-env, which `tc`
-- (util/toggle_colors.sh) writes when cycling color schemes. The file holds the
-- scheme's name, which is also its Neovim theme.

local M = {}

local SCHEME_FILE = vim.fn.expand "~/.color-scheme-env"

local function theme_exists(theme)
  return pcall(require, "base46.themes." .. theme) or pcall(require, "themes." .. theme)
end

-- The Neovim theme from the scheme file, or chadrc's theme if the file is
-- missing or names an unknown theme.
local function read_theme()
  local default = require("chadrc").base46.theme
  local file = io.open(SCHEME_FILE)
  if not file then
    return default
  end
  local theme = (file:read "*l" or ""):match "^[^:]+"
  file:close()
  return theme and theme_exists(theme) and theme or default
end

-- Switch the theme in memory instead of using base46's toggle_theme, which
-- rewrites chadrc.lua on every switch.
local function apply()
  local theme = read_theme()
  local opts = require("nvconfig").base46
  if opts.theme ~= theme then
    opts.theme = theme
    require("base46").load_all_highlights()
  end
end

function M.setup()
  apply()

  -- Poll instead of using a file watcher so it works before the file exists.
  vim.uv.new_fs_poll():start(SCHEME_FILE, 1000, vim.schedule_wrap(apply))
end

return M
