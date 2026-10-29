local M = {}

-- The diffview in the current tab, or nil. Doesn't load diffview if it isn't loaded yet.
function M.current_view()
  if not package.loaded["diffview"] then
    return nil
  end
  return require("diffview.lib").get_current_view()
end

-- Open `path` (relative to the repo) in the diff and put the cursor on `lnum`/`col`
-- in the working-tree side.
local function jump_to(view, path, lnum, col)
  view.emitter:once("file_open_post", function()
    local win = view.cur_layout:get_main_win().id
    vim.api.nvim_win_set_cursor(win, { lnum, math.max(col - 1, 0) })
    vim.api.nvim_win_call(win, function()
      vim.cmd("normal! zvzz")
    end)
  end)
  view:set_file_by_path(path, true, true)
end

-- Live grep over the files in the current diff. Picking a result opens it in the diff
-- instead of replacing the diff pane with a plain buffer.
function M.live_grep(opts)
  local view = M.current_view()
  local toplevel = view.adapter.ctx.toplevel

  local search_dirs = {}
  for _, file in view.files:iter() do
    -- Deleted files aren't on disk to grep.
    if vim.uv.fs_stat(file.absolute_path) then
      table.insert(search_dirs, file.absolute_path)
    end
  end

  local function open_in_diff(prompt_bufnr)
    local entry = require("telescope.actions.state").get_selected_entry()
    require("telescope.actions").close(prompt_bufnr)
    if not entry then
      return
    end
    local path = vim.fs.relpath(toplevel, vim.fn.fnamemodify(entry.filename, ":p"))
    jump_to(view, path, entry.lnum, entry.col)
  end

  require("utils.telescope").live_grep_raw(vim.tbl_extend("force", opts or {}, {
    prompt_title = "Live Grep (diff files)",
    search_dirs = search_dirs,
    mappings = {
      i = { ["<CR>"] = open_in_diff },
      n = { ["<CR>"] = open_in_diff },
    },
  }))
end

return M
