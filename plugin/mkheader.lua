do
	function create_header(title, options)
		options = options or {}
		local width = options.width or 80
		local border_char = options.border_char or '-'
		local bracket_style = options.bracket_style or '[ ]'

		-- Extract bracket chars (e.g., '[ ]' gives '[' and ']')
		local left_bracket, right_bracket = bracket_style:match('^(.)(.)$')
		if not left_bracket then
			left_bracket, right_bracket = '[', ']'
		end

		local content = left_bracket .. ' ' .. title .. ' ' .. right_bracket
		local content_length = #content
		local total_border = width - content_length

		if total_border < 0 then
			return nil, "Title too long for header"
		end

		local left_border = math.floor(total_border / 2)
		local right_border = total_border - left_border

		return string.rep(border_char, left_border) .. content .. string.rep(border_char, right_border)
	end

	-- Main command
	vim.api.nvim_create_user_command('MkHeader', function(opts)
		local header, err = create_header(opts.args, { width = 80 })

		if err then
			vim.notify(err, vim.log.levels.WARN)
		else
			vim.api.nvim_set_current_line(header)
		end
	end, { nargs = 1, desc = 'Create centered 80-char header with -' })

	-- Alternative border styles
	vim.api.nvim_create_user_command('MkHeader2', function(opts)
		local header, err = create_header(opts.args, { width = 80, border_char = '=' })

		if err then
			vim.notify(err, vim.log.levels.WARN)
		else
			vim.api.nvim_set_current_line(header)
		end
	end, { nargs = 1, desc = 'Create centered 80-char header with =' })
	
	vim.api.nvim_create_user_command('MkHeader3', function(opts)
		local header, err = create_header(opts.args, { width = 80, border_char = '|' })

		if err then
			vim.notify(err, vim.log.levels.WARN)
		else
			vim.api.nvim_set_current_line(header)
		end
	end, { nargs = 1, desc = 'Create centered 80-char header with |' })
	
	vim.api.nvim_create_user_command('MkHeader4', function(opts)
		local header, err = create_header(opts.args, { width = 80, border_char = '#' })

		if err then
			vim.notify(err, vim.log.levels.WARN)
		else
			vim.api.nvim_set_current_line(header)
		end
	end, { nargs = 1, desc = 'Create centered 80-char header with #' })
end
