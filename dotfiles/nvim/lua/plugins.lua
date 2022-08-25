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

		-- Run PackerCompile if there are changes saved to this file.
		vim.cmd([[
			augroup packer_user_config
				autocmd!
				autocmd BufWritePost plugins.lua source <afile> | PackerCompile
			augroup end
		]])
  end

  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }

    -- Colorscheme
    use {
      "sainnhe/everforest",
      config = function()
        vim.cmd "colorscheme everforest"
        vim.cmd "set background=light"
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
			}
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
