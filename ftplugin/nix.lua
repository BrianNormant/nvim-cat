vim.lsp.config('nixd', {
	settings = {
		nixd = {
			nixpkgs = {
				expr = nixCats.extra('nixdExtras.nixpkgs')
			},
		},
	},
})
vim.lsp.enable('nixd')
