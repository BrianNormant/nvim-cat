if nixCats('builtin') then
	require('lze').load {{
		'completion.nvim',
		event = 'DeferredUIEnter',
		after = function()
			require('mini.snippets').setup {}
			require('mini.notify').setup {}
			require('mini.completion').setup {
				lsp_completion = {
					source_func = "omnifunc",
				},
				delay = { completion = 10^7, signature = 10^7 },
				window = {
					info = { border = "none" },
					signature = { border = "none" },
				},
				mappings = {
					scroll_up = '',
					scroll_down = '',
				},
			}
			vim.opt_global.completeopt = {
				"menuone",
				"popup",
			}

			-- We control the triggering manually
			vim.g.minicompletion_disable = true

			vim.opt.shortmess:append "c"
			vim.o.pumheight = 20

			---------------------------------[ Fuzzy on ? ]---------------------------------
			_G.completeswitch = false
			local fuzzy = function(original)
				-- This function is called when the user presses
				-- original
				local mode = vim.fn.complete_info({"mode"}).mode
				local map = {
					["keyword"] = "<c-n>",
					["ctrl_x"] = "",
					["whole_line"] = "<c-l>",
					["files"] = "<c-f>",
					["tags"] = "<c-]>",
					["path_defines"] = "<c-d>",
					["path_patterns"] = "<c-i>",
					["dictionary"] = "<c-k>",
					["thesaurus"] = "<c-t>",
					["cmdline"] = "<c-v>",
					["function"] = "<c-u>",
					["omni"] = "<c-o>",
					["spell"] = "<c-s>",
				}
				local invalid = {
					"",
					"spell",
					"eval",
					"unknown",
					"scroll",
				};
				if not vim.tbl_contains(invalid, mode) and not _G.completeswitch then
					vim.opt.completeopt:append "noselect"
					vim.opt.completeopt:append "fuzzy"
					_G.completeswitch = true
					return "<c-e>" .. "<c-x>" .. map[mode]
				else
					return original
				end
			end

			-- AutoCmd to reset completeopt after completion
			vim.api.nvim_create_autocmd({ "CompleteDonePre" }, {
				callback = function()
					if not _G.completeswitch then
						vim.opt_global.completeopt:remove "noselect"
						vim.opt_global.completeopt:remove "fuzzy"
					end
					vim.schedule(function()
						_G.completeswitch = false
					end)
				end,
			})

			-- Apply 
			vim.keymap.set( "i", "/",
			function() return fuzzy("/") end,
			{ expr = true })
			vim.keymap.set( "i", "?",
			function() return fuzzy("?") end,
			{ expr = true })

			--- tabkey to navigated in completion menu
			vim.keymap.set("i", "<Tab>", function()
				if vim.fn.pumvisible() == 1 then
					return "<c-n>"
				else
					return "<Tab>"
				end
			end, {expr = true})
			vim.keymap.set("i", "<S-Tab>", function()
				if vim.fn.pumvisible() == 1 then
					return "<c-p>"
				else
					return "<S-Tab>"
				end
			end, {expr = true})

			--- Up/Down should ignore the completion menu
			vim.keymap.set("i", "<Down>", function()
				if vim.fn.pumvisible() ~= 0 then
					return "<C-e><Down>"
				end
				return "<Down>"
			end, {expr = true, silent = true})
			vim.keymap.set("i", "<Up>", function()
				if vim.fn.pumvisible() ~= 0 then
					return "<C-e><Up>"
				end
				return "<Up>"
			end, {expr = true, silent = true})
		end,
	}}
end
