local map = vim.keymap.set

local general_utils = require("utils.general")

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
      local filepath = vim.fn.expand('%:.')
      os.execute("echo '" .. filepath .."' | " .. general_utils.copy_command())
    end,
    { desc = "copy file path" }
  )

  -- Copy file name
  map(
    "n",
    "<Leader>cfn",
    function()
      local filename = vim.api.nvim_buf_get_name(0):match("^.+/(.+)$")
      os.execute("echo '" .. filename .."' | " .. general_utils.copy_command())
    end,
    { desc = "copy file name" }
  )

  map(
    "v",
    "<Leader>cd",
    function()
        -- Copy visual selection to clipboard.
        vim.api.nvim_exec("call feedkeys('y')", true)

        -- Reselect the last visual selection, since yanking exits visual mode.
        vim.api.nvim_exec("call feedkeys('gv')", true)

        -- Comment out the visual selection.
        vim.api.nvim_feedkeys('gc', 'v', true) -- Sends "hello" in normal mode

        -- Jump to the end of the last visual mode block.
        vim.api.nvim_exec("call feedkeys('`>')", true)

        -- Paste the original code that was copied via yank.
        vim.api.nvim_exec("call feedkeys('p')", true)
    end,
    { desc = "coment and duplicate" }
  )
end
