
if not nixCats('ui') then return end

local tabline = require('tabby.tabline')
local api = require 'tabby.module.api'

local theme = {
	fill = "TabLineFill",
	current_tab = "TabLine",
	tab = "NonText",
	line_sep = "Cursor",
}

local function is_win_modified(win_id)
	if api.is_float_win(win_id) then
		return false
	end
	local bufid = vim.api.nvim_win_get_buf(win_id)
	if vim.bo[bufid].modified then
		return true
	end
	return false
end

local function is_tab_current_win_modified(tab)
	local win_id = api.get_tab_current_win(tab.id)
	return is_win_modified(win_id)
end

tabline.set(function(line)
	return {
		line.tabs().foreach(function(tab)
			local hl = tab.is_current() and theme.current_tab or theme.tab

			local left_sep = tab.is_current()
				and line.sep("▎", theme.line_sep, theme.current_tab)
				or line.sep("▏", theme.line_sep, theme.tab)
			
			local modified = is_tab_current_win_modified(tab)
				and line.sep("+", hl, theme.fill)
				or line.sep(" ", hl, theme.fill)

			return {
				left_sep,
				tab.number(),
				tab.name(),
				modified,
				line.sep(" ", hl, theme.fill),
				hl = hl,
				margin = " ",
			}
		end),
		hl = theme.fill,
	}
end)
