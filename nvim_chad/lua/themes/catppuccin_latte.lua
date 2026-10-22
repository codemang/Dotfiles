-- Catppuccin Latte (light) for NvChad. base46 only ships the dark Mocha
-- variant. Colors from https://catppuccin.com/palette.

local M = {}

M.base_30 = {
  white = "#4c4f69", -- text
  darker_black = "#e6e9ef", -- mantle
  black = "#eff1f5", -- base, nvim bg
  black2 = "#e1e4ea",
  one_bg = "#dce0e8", -- crust
  one_bg2 = "#ccd0da", -- surface0
  one_bg3 = "#c4c8d2",
  grey = "#bcc0cc", -- surface1
  grey_fg = "#acb0be", -- surface2
  grey_fg2 = "#9ca0b0", -- overlay0
  light_grey = "#8c8fa1", -- overlay1
  red = "#d20f39",
  baby_pink = "#e64553", -- maroon
  pink = "#ea76cb",
  line = "#dce0e8", -- for lines like vertsplit
  green = "#40a02b",
  vibrant_green = "#55b03f",
  nord_blue = "#209fb5", -- sapphire
  blue = "#1e66f5",
  yellow = "#df8e1d",
  sun = "#e8a33d",
  purple = "#8839ef", -- mauve
  dark_purple = "#7a2ee0",
  teal = "#179299",
  orange = "#fe640b", -- peach
  cyan = "#04a5e5", -- sky
  statusline_bg = "#e6e9ef",
  lightbg = "#ccd0da",
  pmenu_bg = "#1e66f5",
  folder_bg = "#1e66f5",
  lavender = "#7287fd",
}

M.base_16 = {
  base00 = "#eff1f5", -- base
  base01 = "#e6e9ef", -- mantle
  base02 = "#ccd0da", -- surface0
  base03 = "#bcc0cc", -- surface1
  base04 = "#acb0be", -- surface2
  base05 = "#4c4f69", -- text
  base06 = "#41445e",
  base07 = "#363953",
  base08 = "#d20f39", -- red
  base09 = "#fe640b", -- peach
  base0A = "#df8e1d", -- yellow
  base0B = "#40a02b", -- green
  base0C = "#179299", -- teal
  base0D = "#1e66f5", -- blue
  base0E = "#8839ef", -- mauve
  base0F = "#dd7878", -- flamingo
}

M.polish_hl = {
  treesitter = {
    ["@variable"] = { fg = M.base_30.white },
    ["@property"] = { fg = M.base_30.teal },
    ["@variable.builtin"] = { fg = M.base_30.red },
  },
}

M.type = "light"

M = require("base46").override_theme(M, "catppuccin_latte")

return M
