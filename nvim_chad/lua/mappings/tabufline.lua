local map = vim.keymap.set

return function()
  map(
    "n",
    "<Space>l",
    function()
      require("nvchad.tabufline").next()
    end,
    { desc = "goto next buffer"}
  )

  map(
    "n",
    "<Space>h",
    function()
      require("nvchad.tabufline").prev()
    end,
    { desc ="goto prev buffer" }
  )

  map(
    "n",
    "<Space><Space>l",
    function()
      require("nvchad.tabufline").move_buf(1)
    end,
    { desc ="move buffer to right" }
  )

  map(
    "n",
    "<Space><Space>h",
    function()
      require("nvchad.tabufline").move_buf(-1)
    end,
    { desc ="move buffer to left" }
  )

  map(
    "n",
    "<Space>q",
    function()
      require("nvchad.tabufline").close_buffer()
    end,
    { desc ="close buffer" }
  )
end
