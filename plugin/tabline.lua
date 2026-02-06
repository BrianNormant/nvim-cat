local function get_tabline()
	local tabpages = vim.api.nvim_list_tabpages()
	local cwd = vim.fn.getcwd() .. '/'
	local tab_info = {}

	-- 1. Collect paths
	for _, tabid in ipairs(tabpages) do
		local win = vim.api.nvim_tabpage_get_win(tabid)
		local buf = vim.api.nvim_win_get_buf(win)
		local path = vim.api.nvim_buf_get_name(buf)

		table.insert(tab_info, {
			path = path,
			win_count = #vim.api.nvim_tabpage_list_wins(tabid),
			tabid = tabid,
			filetype = vim.bo[buf].filetype,
			buftype = vim.bo[buf].buftype,
		})
	end

	-- 2. Find Common Ancestor (LCA)
	--- a/b/c/d
	--- a/b/c/d
	--- a/c/c/d
	--- we iterate from a to d
	--- when the directory doesn't match,
	--- we know the rest of the path is
	--- recursive function
	local function get_lca(paths, start)
		if #paths == 0 then
			return ''
		elseif #paths == 1 then
			return vim.fn.fnamemodify(paths[1], ':p:h') .. '/'
		end
		start = start or ''
		local dirs = {}
		local edited = {}

		for _, p in ipairs(paths) do
			local idx, _ = string.find(p, '/', 1, true)
			if idx == nil then return start end
			local dir = string.sub(p, 1, idx - 1)
			local rest = string.sub(p, idx + 1)

			table.insert(edited, rest)
			table.insert(dirs, dir)
		end

		-- get if all equal
		local ref = dirs[1]
		for _, p in ipairs(dirs) do
			if false or
				p == nil or
				p ~= ref then
				return start

			end
		end

		local rest = get_lca(edited, '')
		return ref .. '/' .. rest
	end

	-- Rule for shortening:
	-- Note: . is the cwd
	-- ./A -> A
	-- ./a/A -> a/A
	-- ./a/b/A -> ./../A -- where a/b is a long string

	local file_paths = {}
	for _, i in ipairs(tab_info) do
		if i.filetype ~= '' and
			i.filetype ~= 'fugitive' and
			i.filetype ~= 'minipick' and
			i.filetype ~= 'help' and
			i.filetype ~= 'gitcommit' and
			i.path ~= ""
			then
			table.insert(file_paths, i.path)
		end
	end

	local lca = get_lca(file_paths, '')

	local s = ""
	local cur_tab = vim.api.nvim_get_current_tabpage()

	for i, info in ipairs(tab_info) do
		local display = ""
		local is_active = info.tabid == cur_tab
		-- local active_hl = is_active and "%#TabLineSel#" or "%#TabLine#"
		local active_hl = "%#TabLine#"

		-- Start tab segment
		s = s .. active_hl .. " "
		if is_active then
			s = s .. '| '
		else
			s = s .. "¦ "
		end

		local path = info.path
		local ft = info.filetype
		local bt = info.buftype
		if path == "" and ft == "" then
			display = "[No Name]"
		elseif path == "" then
			display = "[New]"
		elseif ft == "fugitive" then
			display = "[Git]"
		elseif ft == "minipick" then
			display = "[Pick]"
		elseif ft == "help" then
			display = string.format("[Help (%s)]", vim.fn.fnamemodify(path, ':t'))
		elseif ft == "gitcommit" then
			display = "[Commit]"
		else
			display = string.sub(path, #lca + 1)
			if #display > 50 then
				local idx = string.find(display, '/', 1, true)
				local h = string.sub(display, 1, idx - 1)
				local f = vim.fn.fnamemodify(display, ':t')
				display = h .. '/.../' .. f
			end
		end


		s = s .. display .. " "
	end

	return s .. "%#TabLineFill#"
end

function _G.MyTabLine() return get_tabline() end
vim.opt.tabline = "%!v:lua.MyTabLine()"
