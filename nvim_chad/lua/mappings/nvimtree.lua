local map = vim.keymap.set

return function()
  map("n", "<leader>nc", "<cmd> NvimTreeToggle <CR>", { desc = "toggle nvimtree" })
  map("n", "<leader>nf", "<cmd> NvimTreeFocus <CR>", { desc = "focus nvimtree" })
end
