local lze = require('lze')


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
	}
}
