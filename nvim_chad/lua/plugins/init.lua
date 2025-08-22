vim.g.mapleader = ","

return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Better syntax highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "html",
        "javascript",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "typescript",
        "tsx",
        "vim",
      },
    },
  },

  -- Remap escape to 'kj'
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup({
        mappings = {
          i = { k = { j = "<ESC>"}}
        }
      })
    end,
  },

  -- Enable navigating between tmux and vim panes.
  {
    "aserowy/tmux.nvim",
    lazy=false,
    config = function()
      require("tmux").setup({
        navigation = {
          enable_default_keybindings = false,
        },
        resize = {
          enable_default_keybindings = false,
        }
      })
    end,
  },

  -- Speed up FZF.
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        'nvim-telescope/telescope-fzf-native.nvim'
      },
    },
    config=function()
      -- Speed up fuzzy finding.
      -- https://github.com/nvim-telescope/telescope-fzf-native.nvim?tab=readme-ov-file#telescope-setup-and-configuration
      require('telescope').load_extension('fzf')
    end
  },

  -- Show git blame info on each line as virtual text.
  {
    'f-person/git-blame.nvim',
    event = "BufRead",
  },

  -- Show git signs in the left-hand side of the buffer.
  { "lewis6991/gitsigns.nvim" },

  -- Auto-set shift/expand tab amount depending on contents of file.
  -- { "tpope/vim-sleuth" },

  -- Git integration for dealing with commits.
  { "tpope/vim-fugitive", lazy = false  },

  -- Save via sudo.
  { "lambdalisue/vim-suda", keys = { ":" }},

  -- Jump around the screen easily.
  {
    'ggandor/leap.nvim',
    config = function()
      vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
      vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group.
      require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }
    end,

    -- This pluging lazy loads itself, so they advise to disable lazy loading
    -- at the package manager level.
    -- https://github.com/ggandor/leap.nvim?tab=readme-ov-file#installation
    lazy = false
  },

  -- Disable the nvterm.terminal plugin
  {
    "nvterm.terminal",
    enabled = false
  },

  {
    "nvterm",
    enabled = false
  },

  -- Install packages via mason.
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },

    -- https://github.com/haxorg-ux/nvim-yt/blob/b191b7a638bc98e39940044b7069a75fe3d9ae16/lua/plugins/mason.lua#L44
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local mason_tool_installer = require("mason-tool-installer")

      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })

      mason_lspconfig.setup({
        -- list of servers for mason to install
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ruby_lsp",
        },
        -- auto-install configured servers (with lspconfig)
        -- automatic_installation = true, -- not the same as ensure_installed
      })

      mason_tool_installer.setup({
        ensure_installed = {
          "prettier", -- prettier formatter
          "stylua", -- lua formatter
          "isort", -- python formatter
          "black", -- python formatter
          "debugpy", -- python debugger
          "pylint", -- python linter
          "eslint_d", -- js linter
          "ruby_lsp",
          "pyright"
        },
      })
    end
  },

  -- Faster Typescript LSP written in pure lua.
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact" },
    opts = {
      on_attach = function(_, bufnr)
        require("mappings.lsp")(bufnr)
      end
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },

  {
    "nvchad.term",
    enabled = false,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    lazy = false
  }
}
