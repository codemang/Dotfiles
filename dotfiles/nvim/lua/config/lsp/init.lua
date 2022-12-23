local M = {}

local servers = {
  html = {},
  jsonls = {},
  pyright = {},
  sumneko_lua = {
    setup_opts = {
      settings = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        Lua = {
          diagnostics = { globals = { 'vim', 'packer_plugins' } },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
    pre_setup_function = function()
      require("neodev").setup({})
    end,
  },
  tsserver = {},
  vimls = {},
  solargraph = {},
  sqls = {},
  eslint = {},
}

local function on_attach(client, bufnr)
  -- Enable completion triggered by <C-X><C-O>
  -- See `:help omnifunc` and `:help ins-completion` for more information.
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- Use LSP as the handler for formatexpr.
  -- See `:help formatexpr` for more information.
  vim.api.nvim_buf_set_option(0, "formatexpr", "v:lua.vim.lsp.formatexpr()")

  -- Configure key mappings
  require("config.lsp.keymaps").setup(client, bufnr)
end

local lsp_signature = require "lsp_signature"

lsp_signature.setup {
  bind = true,
  handler_opts = {
    border = "rounded",
  },
}

local capabilities = require("cmp_nvim_lsp")
  .default_capabilities(vim.lsp.protocol.make_client_capabilities())

local opts = {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
}

require("config.lsp.handlers").setup()

function M.setup()
  require("config.lsp.installer").setup(servers, opts)
end

return M
