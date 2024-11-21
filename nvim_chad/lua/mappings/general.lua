local map = vim.keymap.set

return function()
  -- Misc optimizations.
  map("n", ";", ":", { desc = "CMD enter command mode" })
  map("n", "<leader>hh", ":noh<CR>", { desc = "hide search highlighting" })
  map("n", "<Leader>j", ":e #<CR>", { desc = "toggle to previously focused buffer" })
  map("n", "<Leader>w", ":w<Cr>")
  map("n", "<Leader>wq", ":wq<Cr>")
  map("n", "<Leader>e", ":e<Cr>")
  map("n", "<Leader>.e", ":e!<Cr>")
  map("n", "<Leader>q", ":q<Cr>")
  map("n", "<Leader>.q", ":q!<Cr>")
  map("n", '<Leader>dd', ":pu=strftime('## %a %d %b %Y')<CR>", { desc = "Print the current date to screen" })
  map("v", "<C-K>", ":move-2<CR>gv=gv", { desc = "Move visual block up one line" })
  map("v", "<C-J>", ":move'>+<CR>gv=gv", { desc = "Move visual block down one line" })

  -- Copy file path
  map(
    "n",
    "<Leader>cfp",
    function()
      local filepath = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. '/', '')
      os.execute("echo '" .. filepath .."' | win32yank.exe -i --crlf")
    end,
    { desc = "copy file path" }
  )

  -- Copy file name
  map(
    "n",
    "<Leader>cfn",
    function()
      local filename = vim.api.nvim_buf_get_name(0):match("^.+/(.+)$")
      os.execute("echo '" .. filename .."' | win32yank.exe -i --crlf")
    end,
    { desc = "copy file name" }
  )
end
