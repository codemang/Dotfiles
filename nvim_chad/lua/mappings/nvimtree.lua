local map = vim.keymap.set

return function()
  map("n", "<leader>nc", "<cmd>Neotree filesystem reveal toggle<CR>", { desc = "toggle nvimtree" })
  map("n", "<leader>nf", "<cmd>Neotree filesystem focus<CR>", { desc = "focus nvimtree" })
end
