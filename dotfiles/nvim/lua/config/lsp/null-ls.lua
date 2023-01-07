-- https://alpha2phi.medium.com/neovim-for-beginners-lsp-using-null-ls-nvim-bd954bf86b40
local M = {}

local nls = require "null-ls"
local nls_utils = require "null-ls.utils"
local b = nls.builtins

local sources = {
  -- formatting
  b.formatting.eslint_d,

  -- diagnostics
  b.diagnostics.eslint_d,
}

function M.setup(opts)
  nls.setup {
    debug = true,
    debounce = 150,
    save_after_format = false,
    sources = sources,
    on_attach = opts.on_attach,
    root_dir = nls_utils.root_pattern ".git",
  }

  -- Auto-format on save.
  -- https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/
  vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
end

return M
