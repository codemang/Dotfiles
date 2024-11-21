local M = {}

-- https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming
function split_string(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

-- Speed up `git status` and other git commands
-- https://github.com/microsoft/WSL/issues/4401#issuecomment-670080585
local function git_command()
  local cwd = vim.loop.cwd()
  local is_in_windows_partition = string.find(cwd, "/mnt/c")
  return is_in_windows_partition and "git.exe" or "git"
end

-- If a 'master' branch exists, return 'master', otherwise return 'main'.
local function main_branch()
  local all_branches = io.popen("git for-each-ref --format='%(refname:short)' refs/heads/"):read("*a")
  local has_master_branch = all_branches:match('master')
  return has_master_branch and 'master' or 'main'
end

local function changed_files()
  -- If you run "git.exe diff" on a branch with no changes from main, it throws
  -- a weird error that it's not running on a Git repo, and the error message
  -- would be visible on the screen. To avoid this, we redirect stderr to
  -- /dev/null.
  local changed_files_string = io.popen(git_command() .. " --no-pager diff --name-only " .. main_branch() .. " 2>/dev/null"):read("*a")
  local files = split_string(changed_files_string)
  return files
end

M.changed_files = changed_files

return M
