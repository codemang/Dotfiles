vim.g.coq_settings = {
  -- Start coq-nvim on boot and don't show the start-up message.
  auto_start = 'shut-up',
  keymap = {
    -- The recommended key mappings override other ones of mine, so I disable
    -- all of them and manually set the ones I want.
    recommended = false,
    -- Override this one specifically so that it doesn't override the
    -- navigation between Tmux and Vim panes.
    jump_to_mark = "<C-m>",
  }
}
