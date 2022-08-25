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
      packer_bootstrap = fn.system {
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

		-- Run PackerCompile if there are changes in this file
    vim.cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
  end

  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }

    -- Colorscheme
    use {
      "sainnhe/everforest",
      config = function()
        vim.cmd "colorscheme everforest"
      end,
    }

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

		use { 
			"aserowy/tmux.nvim", 
			config = function()
				require("tmux").setup({
					-- overwrite default configuration
					-- here, e.g. to enable default bindings
					copy_sync = {
						-- enables copy sync and overwrites all register actions to
						-- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
						enable = true,
					},
					navigation = {
						-- enables default keybindings (C-hjkl) for normal mode
						enable_default_keybindings = true,
					},
					resize = {
						-- enables default keybindings (A-hjkl) for normal mode
						enable_default_keybindings = true,
					}
				})
			end
		}

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
