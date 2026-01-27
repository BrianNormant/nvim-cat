if not nixCats('ui') then return end

require('lze').load {{
	'mini.nvim',
	event = "DeferredUIEnter",
	after = function()
		local function center(text, padding, width)
			local cnt = math.floor((width - #text) / 2)
			local r = string.rep(padding, cnt)
			.. text
			.. string.rep(padding, cnt)
			if #r == width - 1 then
				return r .. padding
			else
				return r
			end
		end
		local mk_mode = function(name)
			return center(name, " ", 7)
		end


		local mode_pair = {
			["n"]    = mk_mode("NOR"),
			-- Normal Operator Pending
			["no"]   = mk_mode("OPER"),
			["nov"]  = mk_mode("OP-C"), -- force movement to be charwise
			["noV"]  = mk_mode("OP-L"), -- force movement to be linewise
			["no"] = mk_mode("OP-B"), -- force movement to be block wise
			-- Insert
			["i"]    = mk_mode("INS"),
			["ix"]   = mk_mode("C-Xi"),
			["ic"]   = mk_mode("C-Oi"),
			-- Replace
			["R"]    = mk_mode("REPL"),
			["Rx"]   = mk_mode("C-Xr"),
			["Rc"]   = mk_mode("C-Or"),
			-- Virtual Replace
			["Rv"]   = mk_mode("vREP"),
			["Rvx"]  = mk_mode("C-XR"),
			["Rvc"]  = mk_mode("C-OR"),
			-- Visual
			["v"]    = mk_mode("VIS"),
			["V"]    = mk_mode("VIS-L"),
			[""]   = mk_mode("VIS-B"),
			-- Select
			["s"]    = mk_mode("SEL"),
			["S"]    = mk_mode("SEL-L"),
			[""]   = mk_mode("SEL-B"),
			-- Terminal
			["t"]    = mk_mode("iTER"),
			["nt"]   = mk_mode("nTER"),
			-- Vim Command
			["c"]    = mk_mode("CLI"),
			-- Select One-Shot Visual (<C-o>)
			["vs"]   = mk_mode("SEL!"),
			["Vs"]   = mk_mode("SEL-L!"),
			["s"]  = mk_mode("SEL-B!"),
			-- One-Shot (<C-o>)
			["niI"]  = mk_mode("INS!"),
			["niR"]  = mk_mode("REPL!"),
			["niV"]  = mk_mode("vREPL!"),
			["ntT"]  = mk_mode("nTER!"),
			-- Others
			["!"]      = mk_mode("WAIT"),
			["r"]    = mk_mode("Prompt"),
			["rm"]   = mk_mode("MORE"),
			["r?"]   = mk_mode("CONFIRM"),
		}

		-- We want to keep a very simple theme
		local melange = require 'lualine.themes.melange'
		melange.normal.a = melange.normal.c
		melange.normal.b = melange.normal.c
		-- melange.normal.c = melange.normal.y
		melange.insert = melange.normal
		melange.replace = melange.normal
		melange.command = melange.normal
		melange.terminal = melange.normal
		melange.visual = melange.normal

		require('lualine').setup {
			options = {
				icons_enabled = false,
				theme = melange,
				component_separators = { left = ' ', right = ' '},
				section_separators = { left = ' ', right = ' '},
				disabled_filetypes = {
					statusline = {},
					winbar = {},
				},
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = true,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
					refresh_time = 16, -- ~60fps
					events = {
						'WinEnter',
						'BufEnter',
						'BufWritePost',
						'SessionLoadPost',
						'FileChangedShellPost',
						'VimResized',
						'Filetype',
						'CursorMoved',
						'CursorMovedI',
						'ModeChanged',
					},
				}
			},
			sections = {
				lualine_a = {
					function()
						local mode = vim.fn.mode(1)
						return mode_pair[mode]
					end
				},
				lualine_b = {'branch', 'diff', 'diagnostics'},
				lualine_c = {'filename'},
				lualine_x = {'filetype'},
				lualine_y = {''},
				lualine_z = {'location'}
			},
		}
	end,
}}
