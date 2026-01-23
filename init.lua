if nixCats('melange') then
	vim.cmd [[colorscheme melange]]
end

vim.g.mapleader = " "

if vim.env.NIXCAT_DEBUG then
	vim.api.nvim_create_user_command(
		"RE",
		"mks! | restart source Session.vim",
		{}
	)
end
