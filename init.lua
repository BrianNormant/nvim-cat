vim.api.nvim_create_autocmd(
	{"ColorScheme"},
	{
		callback = function()
			vim.cmd [[
			highlight clear SpellCap
			highlight clear SpellBad
			highlight clear SpellLocal
			highlight clear SpellRare
			]]
		end
	}
)

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


--- Settings
-- Indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- numberline
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes:3'
-- tabline
vim.opt.showtabline = 2
-- statusline
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
-- other UI tweaks
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.opt.foldlevelstart = 5
vim.opt.list = true

--- Additional Keymaps
-- easy tabpage navigation
for i=1,6 do
	local key = string.format("<A-%d>", i)
	local map = string.format("<cmd>%dtabnext<cr>", i)
	vim.keymap.set('n', key, map, {silent = true})
end

-- easy split
vim.keymap.set('n', '\\', "<cmd>split<cr>")
vim.keymap.set('n', '|', "<cmd>vsplit<cr>")

-- shift + Arrow is the ignored
vim.keymap.set({"n", "x"}, "<S-Down>", "<Down>")
vim.keymap.set({"n", "x"}, "<S-Up>", "<Up>")

-- diagnostics
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- Fuzzy Picker
-- I want to have that integrate with :h preview-window
-- The option are:
-- telescope
-- + Snappy and open fast
-- + Good ecosystem
-- - Laggy on big project
-- + Easy to extend
-- fzf-lua
-- + Ultra fast
-- + Fzf
-- - Slight delay when starting

-- GIT
if nixCats('git') then
	-- fugitive autoload
end


-- OIL
do
	require('oil').setup {}
	vim.keymap.set('n', '<leader>o', require('oil').open)
end
