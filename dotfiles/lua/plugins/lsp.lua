local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ls', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lR', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lc', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
end

local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions
local formatting = null_ls.builtins.formatting

local sources = {
  diagnostics.eslint_d,
  code_actions.eslint_d,
  formatting.eslint_d,
  diagnostics.rubocop.with({
    extra_args = { '--disable-pending-cops' }, -- Remove annoying warnings about unused Cops.
  }),
  formatting.rubocop,
  diagnostics.vint,
  diagnostics.zsh,
  formatting.beautysh.with({
    extra_args = { '--indent-size', '2' },
  }),
}

require("null-ls").setup({
  sources = sources,
  on_attach = on_attach,
})
