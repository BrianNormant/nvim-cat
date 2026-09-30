if nixCats('sql') and nixCats('lsp') and not _G.sql_loaded then
	vim.lsp.enable('postgres_lsp')
	_G.sql_loaded = true
end

local triggers = {'.', ':', ' ', '\n'}
for _, t in pairs(triggers) do
	vim.keymap.set('i', t, function()
		vim.opt.completeopt:append "noselect"
		vim.opt.completeopt:append "fuzzy"
		_G.completeswitch = true
		-- Should check if inside a comment
		if vim.fn.pumvisible() == 0 then
			return t .. '<c-x><c-o>'
		else
			return t
		end
	end, {expr=true, buf=0})
end

vim.keymap.set('v', '<leader>d', ":DB $DBL<cr>")
vim.keymap.set('n', '<leader>d', "vip:DB $DBL<cr>")
