local lsp_installer_servers = require "nvim-lsp-installer.servers"
local utils = require "utils"

local M = {}

function M.setup(servers, options)
  for server_name, _ in pairs(servers) do
    local server_available, server = lsp_installer_servers.get_server(server_name)

    if server_available then
      server:on_ready(function()
        local pre_setup_function = servers[server.name].pre_setup_function
        if pre_setup_function then pre_setup_function() end

        local opts = vim.tbl_deep_extend("force", options, servers[server.name].setup_opts or {})
        server:setup(opts)
      end)

      if not server:is_installed() then
        utils.info("Installing " .. server.name)
        server:install()
        utils.info("Finished Installing " .. server.name)
      end
    else
      utils.error(server)
    end
  end
end

return M
