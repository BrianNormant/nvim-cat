if nixCats('markdown') and not _G.markdown_loaded then
	local lze = require('lze')
	_G.markdown_loaded = true

	lze.load {
		{
			'vimplugin-markdown-preview-nvim',
			before = function()
				lze.trigger_load {'vimplugin-live-server-nvim'}
			end,
			after = function()
				require('markdown_preview').setup {
					port = 8421,
					open_browser = true,
				}
			end
		},
		{
			'vimplugin-live-server-nvim',
			after = function()
				require('live_server').setup {
					default_port = 8000,
					live_reload = { enable = true},
				}
			end
		},
		{
			'markview-nvim',
			after = function()
				require('markview').setup {}
			end,
		}
	}
end
