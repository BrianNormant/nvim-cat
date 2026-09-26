if nixCats('nix') and nixCats('lsp') and not _G.nix_loaded then
	vim.lsp.enable('nixd')
	_G.nix_loaded = true
end
-- Autotrigger

--- Crude autotrigger
local triggers = {'.', '{', '='}
for _, t in pairs(triggers) do
	vim.keymap.set('i', t, function()
		vim.opt.completeopt:append "noselect"
		vim.opt.completeopt:append "fuzzy"
		_G.completeswitch = true
		-- Should check if inside a comment
		return t .. '<c-x><c-o>'
	end, {expr=true, buf=0})
end
