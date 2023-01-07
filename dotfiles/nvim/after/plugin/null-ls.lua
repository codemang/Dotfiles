vim.keymap.set('n', '<Leader>lf', function()
  print "Formatting"
  vim.lsp.buf.format()
  print "Done Formatting"
end, {})
