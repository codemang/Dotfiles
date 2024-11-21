local general_utils = require("utils.general")
local telescope_utils = require("utils.telescope")
local git_utils = require("utils.git")
local map = vim.keymap.set

function choose_changed_files(opts)
  local pickers = require("telescope.pickers")
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values

  local files = git_utils.changed_files()
  opts = opts or {}

  -- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#first-picker
  pickers.new(opts, {
    prompt_title = "Changed Files",
    finder = finders.new_table {
      results = files
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

return function()
  map(
    "n",
    "<Leader>ff",
    function()
      require('telescope.builtin').find_files()
    end,
    { desc = "Live grep by line" }
  )

  map(
    "n",
    "<Leader>fl",
    function()
      require("telescope").extensions.live_grep_args.live_grep_args()
    end,
    { desc = "Live grep by line" }
  )

  map(
    "n",
    "<Leader>fnf",
    function()
      require("telescope.builtin").find_files({ cwd = "~/notes" })
    end,
    { desc = "Fuzzy find note files"}
  )

  map(
    "n",
    "<Leader>fw",
    function()
      local word_under_cursor = vim.api.nvim_eval('expand("<cword>")')
      telescope_utils.live_grep_raw({ default_text = '"' .. word_under_cursor .. '"' })
    end,
    { desc = "Live grep for word under cursor"}
  )

  map(
    "n",
    "<Leader>fnl",
    function()
      telescope_utils.live_grep_raw({ cwd = "~/notes", default_text = "" })
    end,
    { desc = "Live grep for word in the notes directory"}
  )

  map("n", "<Leader>fr", ":Telescope resume<CR>", { desc = "Live grep for word under cursor"})

  map(
    "n",
    "<Leader>fgf",
    function()
       choose_changed_files()
    end,
    { desc = "Select a file that's changed in git"}
  )

  map(
    "n",
    "<Leader>fgl",
    function()
       local files = git_utils.changed_files()
       telescope_utils.live_grep_raw({ default_text = '', search_dirs = files })
    end,
    { desc = "Live grep for a word that is in a changed git file"}
  )

  map(
    "v",
    "<Leader>fv",
    function()
      local visually_selected_text = general_utils.get_visual_selection()
      telescope_utils.live_grep_raw({ default_text = '"' .. visually_selected_text .. '"' })
    end,
    { desc = "Live grep for the word that is visually selected"}
  )
end
