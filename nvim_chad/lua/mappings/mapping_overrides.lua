local alpha_log_file = function()
  local date_process = io.popen("date '+%Y%m%d' -u | tr -d '\n'")
  local date = date_process:read('*a')
  local alpha_log_file = "/mnt/c/Users/nrubin19/AppData/Local/Temp/Bloomberg/Log/bplus." .. date .. ".log"
  date_process:close()
  return alpha_log_file
end

local map = vim.keymap.set

return function()
  map(
    "n",
    "<Leader>ca",
    function()
      os.execute("echo > " .. alpha_log_file())

      if vim.api.nvim_buf_get_name(0) == alpha_log_file() then
        vim.cmd("e!")
      else
        vim.cmd('e ' .. alpha_log_file())
      end
    end,
    { desc = "open alpha" }
  )

  map(
    "n",
    "<Leader>oa",
    function()
      vim.cmd('e ' .. alpha_log_file())
    end,
    { desc = "open alpha" }
  )
end
