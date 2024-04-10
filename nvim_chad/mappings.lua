---@type MappingsTable
local M = {}
local telescope_utils = require("custom.utils.telescope")
local general_utils = require("custom.utils.general")
local comment_utils = require("custom.utils.comment")
local git_utils = require("custom.utils.git")

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

M.general = {
	n = {
		[";"] = { ":", "enter command mode", opts = { nowait = true } },
		["<leader>hh"] = { ":noh<CR>", "hide search highlighting" },
		["<Leader>j"] = { ":e #<CR>", "toggle to previously focused buffer" },
		["<Leader>w"] = { ":w<Cr>" },
		["<Leader>wq"] = { ":wq<Cr>" },
		["<Leader>e"] = { ":e<Cr>" },
		["<Leader>.e"] = { ":e!<Cr>" },
		["<Leader>q"] = { ":q<Cr>" },
		["<Leader>.q"] = { ":q!<Cr>" },
    ['<Leader>dd'] = { ":pu=strftime('## %a %d %b %Y')<CR>", "Print the current date to screen" },
	},
}

-- In order to disable a default keymap, use
M.disabled = {
	n = {
		["<C-l>"] = "",
		["<leader>fw"] = "", -- Set by nvchad telescope config
		["<leader>e"] = "", -- Set by nvchad nvimtree config
		["<leader>q"] = "", -- Set by nvchad lsp config
		["<leader>/"] = "", -- Set by nvchad comment
	},
}

M.tmuxNvim = {
	plugin = true,

	n = {
		["<C-l>"] = {
			function()
				require("tmux").move_right()
			end,
			"move to right tmux pane",
		},
		["<C-h>"] = {
			function()
				require("tmux").move_left()
			end,
			"move to right tmux pane",
		},
		["<C-k>"] = {
			function()
				require("tmux").move_top()
			end,
			"move to above tmux pane",
		},
		["<C-j>"] = {
			function()
				require("tmux").move_bottom()
			end,
			"move to below tmux pane",
		},
	},
}

M.nvimtree = {
	plugin = true,

	n = {
		-- toggle
		["<leader>nc"] = { "<cmd> NvimTreeToggle <CR>", "toggle nvimtree" },

		-- focus
		["<leader>nf"] = { "<cmd> NvimTreeFocus <CR>", "focus nvimtree" },
	},
}

M.comment = {
	plugin = true,

	v = {
		["<leader>/d"] = {
			function()
				-- Copy visual selection to clipboard.
				vim.api.nvim_exec("call feedkeys('y')", true)

				-- Reselect the last visual selection, since yanking exits visual mode.
				vim.api.nvim_exec("call feedkeys('gv')", true)

				-- Comment out the visual selection.
				comment_utils.comment_visual_selection()

        -- Exit visual mode.
        -- vim.api.nvim_exec("call feedkeys('V')", true)

				-- Jump to the end of the last visual mode block.
				vim.api.nvim_exec("call feedkeys('`>')", true)

				-- Paste the original code that was copied via yank.
				vim.api.nvim_exec("call feedkeys('p')", true)
			end,
			"comment and duplicate block",
		},
	},

  n = {
    ["<leader>//"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "toggle comment",
    },
  }
}

M.telescope = {
	plugin = true,

	n = {
		["<Leader>fl"] = {
			function()
				require("telescope").extensions.live_grep_args.live_grep_args()
			end,
			"Live grep by line",
		},
		["<Leader>fnf"] = {
			function()
				require("telescope.builtin").find_files({ cwd = "~/notes" })
			end,
			"Fuzzy find note files",
		},
		["<Leader>fw"] = {
			function()
				local word_under_cursor = vim.api.nvim_eval('expand("<cword>")')
				telescope_utils.live_grep_raw({ default_text = '"' .. word_under_cursor .. '"' })
			end,
			"Live grep for word under cursor",
		},
		["<Leader>fnl"] = {
			function()
				telescope_utils.live_grep_raw({ cwd = "~/notes", default_text = "" })
			end,
			"Live grep for word in the notes directory",
		},
		["<Leader>fr"] = {
			":Telescope resume<CR>",
			"Live grep for word under cursor",
		},
		["<Leader>fgf"] = {
			function()
        choose_changed_files()
			end,
			"Select a file that's changed in git",
		},
		["<Leader>fgl"] = {
			function()
        local files = git_utils.changed_files()
        telescope_utils.live_grep_raw({ default_text = '', search_dirs = files })
			end,
			"Live grep for a word that is in a changed git file",
		}
	},
	v = {
		["<Leader>fv"] = {
			function()
				local visually_selected_text = general_utils.get_visual_selection()
				telescope_utils.live_grep_raw({ default_text = '"' .. visually_selected_text .. '"' })
			end,
			"Live grep for the word that is visually selected",
		},
	},
}

M.tabufline = {
	plugin = true,

	n = {
		["<Space>l"] = {
			function()
				require("nvchad.tabufline").tabuflineNext()
			end,
			"goto next buffer",
		},
		["<Space>h"] = {
			function()
				require("nvchad.tabufline").tabuflinePrev()
			end,
			"goto prev buffer",
		},
		["<Space><Space>l"] = {
			function()
				require("nvchad.tabufline").move_buf(1)
			end,
			"move buffer to right",
		},
		["<Space><Space>h"] = {
			function()
				require("nvchad.tabufline").move_buf(-1)
			end,
			"move buffer to left",
		},
		["<Space>q"] = {
			function()
				require("nvchad.tabufline").close_buffer()
			end,
			"close buffer",
		},
	},
}

M.highlight_search = {
    plugin = true,

    n = {
        ["n"] = {
            function()
                require("highlight_current_n").n()
            end,
            "move to next search match",
        },
        ["N"] = {
            function()
                require("highlight_current_n").N()
            end,
            "move to previous search match",
        },
    }
}

return M
