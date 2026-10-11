if nixCats('rest') and not _G.http_loaded then
	local lze = require('lze')
	_G.http_loaded = true

	lze.load {
		{
			'vimplugin-resty-nvim',
			after = function()
				require('resty').setup {}
			end,
		}
	}
end

vim.cmd "set ft=resty"
