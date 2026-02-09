if nixCats('nix') and nixCats('lsp') and not _G.nix_loaded then
	vim.lsp.enable('nixd')
	_G.nix_loaded = true
end
