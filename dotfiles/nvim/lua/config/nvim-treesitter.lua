local M = {}

function M.setup()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "css",
      "html",
      "json",
      "http",
      "javascript",
      "lua",
      "markdown",
      "python",
      "typescript",
      "yaml",
      "bash",
    },
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = true,
    },
    indent = {
      enable = true
    },
    autotag = { enable = true, },
    -- Add support for end completion for Ruby, Lua, etc.
    -- https://github.com/RRethy/nvim-treesitter-endwise
    endwise = {
      enable = true,
    },
  })
end

return M
