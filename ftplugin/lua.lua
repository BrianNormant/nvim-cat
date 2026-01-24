if nixCats('lua') then
	if nixCats('lsp') then
		vim.cmd.packadd('lazydev.nvim')
		require('lazydev').setup {
			library = {
				{ path = nixCats.nixCatsPath and nixCats.nixCatsPath .. 'lua' or nil, words = { "nixCats" } },
			},
		}
		vim.lsp.config('lua_ls', {
			settings = {
				Lua = {
					formatters = {
						ignoreComments = true,
					},
					signatureHelp = { enabled = true },
					diagnostics = {
						globals = { 'vim', 'nixCats' },
						disable = { 'missing-fields' },
					},
					runtime = {
						-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
						version = "LuaJIT",
						path = vim.split(package.path, ";"),
					},
				},
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
				},
				checkThirdParty = false,
			},
		})
		--- Crude autotrigger
		local triggers = {'.', ':'}
		for _, t in pairs(triggers) do
			vim.keymap.set('i', t, function()
				vim.opt.completeopt:append "noselect"
				vim.opt.completeopt:append "fuzzy"
				_G.completeswitch = true
				-- Should check if inside a comment
				return t .. '<c-x><c-o>'
			end, {expr=true, buffer=true})
		end

		vim.lsp.enable("lua_ls")
	end
	if nixCats('lint') then

	end
	if nixCats('format') then

	end
	if nixCats('dap') then

	end
end
