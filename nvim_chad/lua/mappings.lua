require "nvchad.mappings"

require("mappings.general")()
require("mappings.telescope")()
require("mappings.nvimtree")()
require("mappings.tmux")()
require("mappings.tabufline")()

local function load_mapping_overrides()
  require("mappings.mapping_overrides")()
end

-- Wrap in `pcall` since file might not exist, and we want to catch that error.
pcall(load_mapping_overrides)
