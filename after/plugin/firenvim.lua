if vim.g.started_by_firenvim == true then
	vim.o.laststatus = 0
	vim.o.cmdheight = 0
	vim.o.showtabline = 0
	vim.o.signcolumn = 'auto:1'
	vim.g.firenvim_config.localSettings['.*'] = { cmdline = 'neovim' }

	if vim.opt.lines:get() < 10 then vim.opt.lines = 10 end
	if vim.opt.columns:get() < 80 then vim.opt.colums = 80 end
end
