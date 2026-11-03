-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "bearded-arc",

	-- `tc` cycles through the themes in COLOR_SCHEMES (util/toggle_colors.sh).
	-- This theme is used when no scheme has been picked yet.

	-- The theme's changed-line and changed-word backgrounds are nearly black, so in
	-- diffs only the gutter shows a change. Style them like added lines (DiffAdd): the
	-- changed line gets the added-line background, and the changed words also get the
	-- green text and a stronger green background so they stand out within the line.
	hl_override = {
		DiffChange = { bg = { "green", "black", 90 }, fg = "NONE" },
		DiffText = { bg = { "green", "black", 75 }, fg = "green", bold = true },
	},
}

return M
