-- Comment on a visual selection and paste it into a Claude pane's input via herdr,
-- in the same `path:start-end` / snippet / comment format as herdr-reviewr.
local M = {}

local PASTE_START = "\27[200~"
local PASTE_END = "\27[201~"

-- Agent pane picked per repo root, so later comments skip the picker.
local chosen_pane = {}

-- diffview buffer names embed the git dir (e.g. `<repo>/.git/worktrees/<name>`), which would
-- resolve to the main repo, so those use the working directory instead.
local function repo_root()
  if not vim.api.nvim_buf_get_name(0):match("^diffview://") then
    local root = vim.fs.root(0, ".git")
    if root then
      return root
    end
  end
  return vim.fs.root(vim.fn.getcwd(), ".git")
end

-- The selection's location relative to the repo. diffview names its revision buffers
-- `diffview://<git-dir>/<rev>/<path>`, so those report the revision they show.
local function location(root, start_line, end_line)
  local range = start_line == end_line and tostring(start_line) or (start_line .. "-" .. end_line)
  local name = vim.api.nvim_buf_get_name(0)

  if name:match("^diffview://") then
    local git_dir = vim.trim(vim.fn.system({ "git", "-C", root, "rev-parse", "--absolute-git-dir" }))
    local rev, path = name:sub(#("diffview://" .. git_dir .. "/") + 1):match("^([^/]+)/(.+)$")
    if path then
      return ("%s:%s (at %s)"):format(path, range, rev)
    end
  end

  return ("%s:%s"):format(vim.fs.relpath(root, name) or vim.fn.fnamemodify(name, ":."), range)
end

local function claude_agents()
  local result = vim.system({ "herdr", "agent", "list" }, { text = true }):wait()
  if result.code ~= 0 then
    return nil, "herdr agent list failed: " .. vim.trim(result.stderr or "")
  end
  local agents = vim.tbl_filter(function(agent)
    return agent.agent == "claude"
  end, vim.json.decode(result.stdout).result.agents)
  return agents
end

-- Calls `on_agent` with the Claude agent to send to: the remembered one, the only one in
-- this repo, or the user's pick (falling back to every Claude agent if none is in this repo).
local function pick_agent(root, on_agent)
  local agents, err = claude_agents()
  if not agents then
    return vim.notify(err, vim.log.levels.ERROR)
  end

  local remembered = vim.tbl_filter(function(agent)
    return agent.pane_id == chosen_pane[root]
  end, agents)
  if #remembered == 1 then
    return on_agent(remembered[1])
  end

  local in_repo = vim.tbl_filter(function(agent)
    return agent.cwd == root
  end, agents)
  if #in_repo == 1 then
    return on_agent(in_repo[1])
  end

  local candidates = #in_repo > 0 and in_repo or agents
  if #candidates == 0 then
    return vim.notify("No Claude agents running in herdr", vim.log.levels.WARN)
  end

  vim.ui.select(candidates, {
    prompt = "Send to which Claude?",
    format_item = function(agent)
      return ("%s  [%s]  %s"):format(agent.terminal_title_stripped, agent.agent_status, agent.cwd)
    end,
  }, function(agent)
    if agent then
      chosen_pane[root] = agent.pane_id
      on_agent(agent)
    end
  end)
end

local function send(agent, text)
  if agent.agent_status == "blocked" then
    return vim.notify("Answer the Claude prompt first, it would drop the paste", vim.log.levels.WARN)
  end

  -- One bracketed paste, so newlines don't submit and nothing inside can end the paste early.
  local body = text:gsub(vim.pesc(PASTE_END), "")
  local result = vim.system({ "herdr", "pane", "send-text", agent.pane_id, PASTE_START .. body .. "\n\n" .. PASTE_END }):wait()
  if result.code ~= 0 then
    return vim.notify("herdr send-text failed: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
  end
  vim.notify("Comment sent to " .. agent.terminal_title_stripped)

  -- Jump to the agent so the comment can be edited and submitted, as herdr-reviewr does.
  vim.system({ "herdr", "agent", "focus", agent.pane_id })
end

-- Call from visual mode.
function M.comment()
  vim.cmd("normal! \27")
  local start_line = vim.api.nvim_buf_get_mark(0, "<")[1]
  local end_line = vim.api.nvim_buf_get_mark(0, ">")[1]
  local snippet = table.concat(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")

  local root = repo_root()
  if not root then
    return vim.notify("Not in a git repo", vim.log.levels.WARN)
  end
  local loc = location(root, start_line, end_line)

  vim.ui.input({ prompt = "Comment on " .. loc .. ": " }, function(comment)
    if not comment or vim.trim(comment) == "" then
      return
    end
    pick_agent(root, function(agent)
      send(agent, table.concat({ loc, snippet, comment }, "\n"))
    end)
  end)
end

-- Forget the remembered agent for this repo, so the next comment asks again.
function M.reset_target()
  local root = repo_root()
  if root then
    chosen_pane[root] = nil
  end
end

return M
