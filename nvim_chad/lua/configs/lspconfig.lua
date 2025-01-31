-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "pyright", "ruby_lsp" }
local nvlsp = require "nvchad.configs.lspconfig"

local on_attach = function(_, bufnr)
  require("mappings.lsp")(bufnr)
end

-- Place server overrides here.
extensions = {}

-- lsps with default config
for _, lsp in ipairs(servers) do
  extension = extensions[lsp]
  if extension == nil then extension = {} end

  default_config = {
    on_attach = on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }

  final_config = vim.tbl_extend("force", default_config, extension)

  lspconfig[lsp].setup(final_config)
end
