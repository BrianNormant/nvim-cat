if nixCats('luaft') and nixCats('lsp') and not _G.lua_loaded then
	vim.cmd.packadd('lazydev.nvim')
	require('lazydev').setup {
		library = {
			{ path = nixCats.nixCatsPath and nixCats.nixCatsPath .. 'lua' or nil, words = { "nixCats" } },
		},
	}
	vim.lsp.config('lua_ls', {
		handlers = {
			['$/progress'] = function(_) end,
		},
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

	vim.lsp.enable("lua_ls")
	_G.lua_loaded = true
end

--- Crude autotrigger
local triggers = {'.', ':'}
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

vim.keymap.set("v", "<leader>d", "<leader>sc", {buf=0})
