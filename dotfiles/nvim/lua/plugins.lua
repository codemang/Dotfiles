-- Source https://alpha2phi.medium.com/neovim-for-beginners-init-lua-45ff91f741cb

local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    display = {
      open_fn = function()
        -- Open the packer.vim status window in a floating window, not the
        -- default vertical split.
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  -- Download packer.nvim automatically for us.
  local function packer_init()
    local fn = vim.fn
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

    -- Download packer.nvim if it hasn't been downloaded yet.
    if fn.empty(fn.glob(install_path)) > 0 then
      local packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      }

      -- Load packer.nvim right after installing it.
      vim.cmd [[packadd packer.nvim]]
    end

    -- Run PackerCompile if there are changes saved to this file.
    vim.cmd([[
			augroup packer_user_config
				autocmd!
				autocmd BufWritePost plugins.lua source <afile> | PackerCompile
			augroup end
		]] )
  end

  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }

    -- Git
    use {
      "TimUntersberger/neogit",
      requires = "nvim-lua/plenary.nvim",
      config = function()
        require("config.neogit").setup()
      end,
    }

    -- Startup screen
    use {
      "goolord/alpha-nvim",
      config = function()
        require("config.alpha").setup()
      end,
    }

    use { "aserowy/tmux.nvim",
      config = function()
        require("config.tmux").setup()
      end,
    }

    use {
      'nvim-telescope/telescope.nvim',
      config = function()
        require("config.telescope").setup()
      end,
      requires = {
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-live-grep-args.nvim",
      }
    }

    use {
      'romgrk/barbar.nvim',
      requires = { 'kyazdani42/nvim-web-devicons' },
      config = function()
        require("config.barbar").setup()
      end,
    }

    -- Needed for auto-complete + LSP integration. Didn't work when just used as a required package for the completion plugin.
    use { "hrsh7th/cmp-nvim-lsp" }

    use {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      opt = true,
      config = function()
        require("config.cmp").setup()
      end,
      requires = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",
        "ray-x/cmp-treesitter",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-calc",
        "f3fora/cmp-spell",
        "hrsh7th/cmp-emoji",
        "rafamadriz/friendly-snippets",
        {
          "L3MON4D3/LuaSnip",
          wants = "friendly-snippets",
          config = function()
            require("config.luasnip").setup()
          end,
        },
      },
    }

    use {
      'kyazdani42/nvim-tree.lua',
      requires = {
        'kyazdani42/nvim-web-devicons', -- optional, for file icons
      },
      config = function()
        require("config.nvim-tree").setup()
      end,
      tag = 'nightly' -- optional, updated every week. (see issue #1193)
    }

    -- Auto pairs
    use {
      "windwp/nvim-autopairs",
      requires = { "nvim-treesitter/nvim-treesitter" },
      module = { "nvim-autopairs.completion.cmp", "nvim-autopairs" },
      config = function()
        require("config.nvim-autopairs").setup()
      end,
    }

    -- Better syntax highlighting.
    -- Needed for nvim-ts-autotag to work.
    use {
      "nvim-treesitter/nvim-treesitter",
      requires = {
        "RRethy/nvim-treesitter-endwise",
      },
      config = function()
        require("config.nvim-treesitter").setup()
      end,
    }

    -- Auto tag
    use {
      "windwp/nvim-ts-autotag",
      requires = { "nvim-treesitter/nvim-treesitter" },
    }

    use {
      "neovim/nvim-lspconfig",
      config = function()
        require("config.lsp").setup()
      end,
      requires = {
        "williamboman/nvim-lsp-installer",
        "ray-x/lsp_signature.nvim",
        "folke/neodev.nvim",
        "jose-elias-alvarez/null-ls.nvim",
        {
          "j-hui/fidget.nvim",
          config = function()
            require("fidget").setup {}
          end,
        },
      },
    }

    use {
      "folke/which-key.nvim",
      event = "VimEnter",
    }

    use {
      'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup({
          mappings = {
            basic = false,
            extra = false,
            extended = false,
          },
        })
      end
    }

    use {
      "nvim-lualine/lualine.nvim",
      event = "VimEnter",
      config = function()
        require("config.lualine").setup()
      end,
      requires = { "nvim-web-devicons" },
    }

    use { "sainnhe/edge" } -- Light colorscheme
    use { "sainnhe/sonokai" } -- Dark colorscheme

    use {
      'fedepujol/move.nvim',
      config = function()
        require("config.move")
      end,
    }

    use {
      'rhysd/git-messenger.vim',
      config = function()
        require("config.git-messenger").setup()
      end,
    }

    use {
      'f-person/git-blame.nvim',
      config = function()
        require("config.git-blame").setup()
      end,
    }

    use { 'karb94/neoscroll.nvim' }

    -- Show a scrollbar in each buffer.
    use {
      'petertriho/nvim-scrollbar',
      config = function()
        require("config.nvim-scrollbar").setup()
      end,
    }

    use {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("config.gitsigns").setup()
      end
    }

    -- Customize the wildmenu
    use {
      'gelguy/wilder.nvim',
      config = function()
        require("config.wilder").setup()
      end,
    }

    -- Update the quickfix window to have a preview.
    use {
      'kevinhwang91/nvim-bqf',
      ft = 'qf'
    }

    -- Used by 'nvim-bqf'
    use {
      'junegunn/fzf',
      run = function()
        vim.fn['fzf#install']()
      end
    }

    -- Highlight open/close tag pairs.
    use { 'andymass/vim-matchup' }

    use { 'dkarter/bullets.vim' }

    if packer_bootstrap then
      print "Restart Neovim required after installation!"
      require("packer").sync()
    end
  end

  packer_init()

  local packer = require "packer"
  packer.init(conf)
  packer.startup(plugins)
end

return M
