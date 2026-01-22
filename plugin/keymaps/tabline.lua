for i=1,6 do
	key = string.format("<A-%d>", i)
	map = string.format("<cmd>%dtabnext<cr>", i)
	vim.keymap.set('n', key, map, {silent = true})
end
