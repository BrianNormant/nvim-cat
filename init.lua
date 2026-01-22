-- if the colorscheme if gruvbox, we load the plugin, and set the scheme
if nixCats('gruvbox') then
	require('gruvbox-material').setup {
		contrast = "soft",
	}
	vim.cmd [[colorscheme gruvbox-material]]
end

if vim.env.NIXCAT_DEBUG then
	-- We are restarting nvim with :restart
	vim.cmd [[source ./Session.vim]]
end
