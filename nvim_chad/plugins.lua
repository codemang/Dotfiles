local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  -- Install a plugin
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup({
        mapping = {"kj"}, -- a table with mappings to use
      })
    end,
  },

  { "aserowy/tmux.nvim",
    init = require("core.utils").load_mappings "tmuxNvim",
    config = function()
      require "custom.configs.tmux-nvim" -- just an example path
    end,
  },


  {
    "nvim-telescope/telescope.nvim",
    opts = overrides.telescope,
    dependencies = {
        { "nvim-telescope/telescope-live-grep-args.nvim",  'nvim-telescope/telescope-fzf-native.nvim' },
    }
  },

  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  {
    'f-person/git-blame.nvim',
    event = "BufRead",
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = overrides.gitsigns,
  },

  { "tpope/vim-sleuth" },

  { "tpope/vim-fugitive", lazy = false  },

  { "lambdalisue/vim-suda", keys = { ":" }},


  -- To make a plugin not be loaded
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   enabled = false
  -- },

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}

return plugins
