-- if the colorscheme if gruvbox, we load the plugin, and set the scheme
if nixCats('gruvbox') then
	require('gruvbox-material').setup {
		contrast = "soft",
	}
	vim.cmd [[colorscheme gruvbox-material]]
end

vim.g.mapleader = " "

if vim.env.NIXCAT_DEBUG then
	vim.api.nvim_create_user_command(
		"RE",
		"mks! | restart source Session.vim",
		{}
	)
end
