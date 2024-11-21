local M = require("nvchad.configs.treesitter").defaults()

table.insert(M["ensure_installed"], "tsx")
table.insert(M["ensure_installed"], "typescript")

return M
