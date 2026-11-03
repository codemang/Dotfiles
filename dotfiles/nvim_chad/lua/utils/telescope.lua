local M = {}

-- https://github.com/nvim-telescope/telescope-live-grep-args.nvim/issues/14
M.live_grep_raw = function(opts, mode)
	opts = opts or {}

	if not opts.default_text then
		if mode then
			opts.default_text = '"' .. escape_rg_text(get_text(mode)) .. '"'
		else
			opts.default_text = '"'
		end
	end

	require('telescope').extensions.live_grep_args.live_grep_args(opts)
end

return M
