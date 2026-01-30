-- =============================[ Colorscheme ]=================================
vim.api.nvim_create_autocmd(
	{"ColorScheme"},
	{
		callback = function()
			vim.cmd [[
			highlight clear SpellCap
			highlight clear SpellBad
			highlight clear SpellLocal
			highlight clear SpellRare
			" highlight! link Search PmenuSel
			" highlight! link IncSearch PmenuSel
			" highlight! link CurSearch FloatShadow
			" highlight Substitute guibg=#545454
			]]
			if nixCats('melange') then
				vim.cmd [[
				highlight CursorLine  guibg=#3C3836
				highlight TabLine     guibg=#32302F guifg=#c1a78e
				highlight TabLineSel  guibg=#3C3836 guifg=#c1a78e
				highlight TabLineFill guibg=#32302F
				]]
			end
		end
	}
)
-- TODO: Find a better bg for the cursorline
if nixCats('melange') then
	vim.cmd [[colorscheme melange]]
end

if nixCats('debug') then
	vim.g.startuptime_exe_path = "/home/brian/.config/nvim-cat/result/bin/nvim"
end

-- Must be set for settings mapping with <leader>
vim.g.mapleader = " "

-----------------------------[ Hot Reload config ]------------------------------
if vim.env.NIXCAT_DEBUG then
	vim.api.nvim_create_user_command(
		"RE",
		"mks! | restart source Session.vim",
		{}
	)
end

--- Settings
vim.opt.smartcase = true
vim.opt.ignorecase = true
-- Indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
-- numberline
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes:3'
-- tabline
vim.opt.showtabline = 2
-- statusline
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
-- other UI tweaks
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.opt.foldlevelstart = 5
vim.opt.foldmethod = 'syntax'
vim.opt.list = true
-- spell
vim.opt.spell = true
vim.opt.spelllang = {
	"en",
	"fr",
}
vim.opt.spelloptions = {
	"camel",
}

-- Highlight on yank
vim.cmd [[
autocmd TextYankPost * silent! lua vim.hl.on_yank {higroup = 'Visual', timeout = 150}
]]

--- Additional Keymaps
-- easy tabpage navigation
for i=1,6 do
	local key = string.format("<A-%d>", i)
	local map = string.format("<cmd>%dtabnext<cr>", i)
	vim.keymap.set('n', key, map, {silent = true})
end

-- easy split
vim.keymap.set('n', '\\', "<cmd>split<cr>")
vim.keymap.set('n', '|', "<cmd>vsplit<cr>")
vim.opt.splitbelow = true

-- shift + Arrow is the ignored
vim.keymap.set({"n", "x"}, "<S-Down>", "<Down>")
vim.keymap.set({"n", "x"}, "<S-Up>", "<Up>")

-- open diag
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- toggle preview-window
vim.keymap.set("n", "<c-p>", function()
	-- Check if preview window is open in tabpage
	local preview_win = nil
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_get_option_value('previewwindow', {win = win}) then
			preview_win = win
			break
		end
	end
	if preview_win then
		vim.cmd 'pclose'
	else
		vim.cmd 'pedit'
	end
end)

require('preview')

vim.cmd [[
" https://caleb89taylor.medium.com/customizing-individual-neovim-windows-4a08f2d02b4e
" Call method on window enter
augroup WindowManagement
	autocmd!
	autocmd FileType * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
	if &previewwindow
		setlocal winhighlight+=Normal:PmenuSel
		setlocal winhighlight+=CursorLine:PmenuSel
	endif
endfunction
]]
----------------------------------[ Session ]-----------------------------------
vim.keymap.set("n", "<leader>s", function()
	-- TODO: ask for confirmation
	vim.cmd 'source Session.vim'
	vim.notify "Session Loaded"
end)
vim.keymap.set("n", "<leader>S", function()
	-- TODO: ask for confirmation
	vim.cmd 'mks!'
	vim.notify "Session Saved"
end)

vim.api.nvim_create_user_command('Copen', function()
	vim.cmd('copen')
	vim.cmd('wincmd p')  -- Go back to previous window
end, {})

-- ================================[ Extras ]===================================
-- stuff that are nice (event required imo) to have but require external plugins
-- the generale nature of those plugins is to extend neovim core functionnality

----------------------------------[ UndoTree ]----------------------------------
vim.cmd.packadd "nvim.undotree"
vim.keymap.set("n", "<A-u>", "<cmd>Undotree<cr>")

------------------------------[ Highlight Search ]------------------------------
if nixCats('builtin') then
	require("auto-hlsearch").setup({
		remap_keys = { "/", "?", "*", "#", "n", "N" },
		create_commands = true,
	})
end
vim.cmd.packadd "nohlsearch"
vim.opt.updatetime = 2000

-- ===================[ Operators, Movement & textobject ]======================
if nixCats('leap') then
	vim.keymap.set({ "n", "x" }, "s",
	function()
		return '<Plug>(leap-anywhere)'
	end,{expr=true})
	vim.keymap.set({ "n", "x" }, "S", function()
		require('leap.treesitter').select {
			opts = require('leap.user').with_traversal_keys("s", "S")
		}
	end)
	vim.keymap.set({ "o" }, "s", '<Plug>(leap)')
	-- vim.keymap.set({ "o" }, "S", flash.treesitter_search)
	vim.keymap.set({ "o" }, "r", function()
		require('leap.remote').action {
			input = vim.fn.mode("true"):match('o') and '' or 'v'
		}
	end)

	-- conflict in quicklist list
	-- require('leap.user').set_repeat_keys('<enter>', '<backspace>')

	-- Automatic paste after remote yank operations:
	vim.api.nvim_create_autocmd('User', {
		pattern = 'RemoteOperationDone',
		group = vim.api.nvim_create_augroup('LeapRemote', {}),
		callback = function (event)
			if vim.v.operator == 'y' and event.data.register == '"' then
				vim.cmd('normal! p')
			end
		end,
	})
	local function as_ft (key_specific_args)
		local common_args = {
			inputlen = 1,
			inclusive = true,
			opts = {
				safe_labels = vim.fn.mode(1):match'[no]' and '' or nil,
			},
		}
		return vim.tbl_deep_extend('keep', common_args, key_specific_args)
	end

	local clever = require('leap.user').with_traversal_keys
	local clever_f = clever('f', 'F')
	local clever_t = clever('t', 'T')

	for key, key_specific_args in pairs {
		f = { opts = clever_f, },
		F = { backward = true, opts = clever_f },
		t = { offset = -1, opts = clever_t },
		T = { backward = true, offset = 1, opts = clever_t },
	} do
	vim.keymap.set({'n', 'x', 'o'}, key, function ()
		require('leap').leap(as_ft(key_specific_args))
	end)
end
end
if nixCats('builtin') then
	do
		local spider = require('spider')
		spider.setup {}
		vim.keymap.set({"n", "o", "x"}, "w", "<cmd>lua require('spider').motion('w')<cr>")
		vim.keymap.set({"n", "o", "x"}, "e", "<cmd>lua require('spider').motion('e')<cr>")
		vim.keymap.set({"n", "o", "x"}, "b", "<cmd>lua require('spider').motion('b')<cr>")
		vim.keymap.set({"n", "o", "x"}, "ge", "<cmd>lua require('spider').motion('ge')<cr>")
		vim.keymap.set("i", "<C-f>", function() spider.motion('w') end)
		vim.keymap.set("i", "<C-b>", function() spider.motion('b') end)
	end
	-- mini.bracketed
	require('mini.pairs').setup {
		mappings = {
			['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
			['>'] = { action = 'close', pair = '<>', neigh_pattern = '[^\\].' },
		}
	}
	require('mini.ai').setup {}
	require('mini.move').setup {}
	require('mini.align').setup {}
	require('mini.operators').setup {
		replace = { prefix = "zp", },
		-- conflict with a weird neovim default, :h zp
	}

	require('mini.comment').setup()
	require('mini.surround').setup({
		mappings = {
			add = 'ys',
			delete = 'ds',
			find = '',
			find_left = '',
			highlight = '',
			replace = 'cs',

			-- Add this only if you don't want to use extended mappings
			suffix_last = '',
			suffix_next = '',
		},
		search_method = 'cover_or_next',
	})

	-- Remap adding surrounding to Visual mode selection
	vim.keymap.del('x', 'ys')
	vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

	-- Make special mapping for "add surrounding for line"
	vim.keymap.set('n', 'yss', 'ys_', { remap = true })
end

---------------------------------[ treesitter ]---------------------------------
if nixCats('treesitter') then
	vim.api.nvim_create_autocmd('BufReadPre', {
		group = vim.api.nvim_create_augroup('TSConfig', {}),
		callback = function()
			vim.cmd.packadd 'nvim-treesitter'
			vim.cmd.packadd 'nvim-treesitter-legacy'
			vim.cmd.packadd 'treesj'
			local tsj = require('treesj')
			tsj.setup {}
			vim.keymap.set("n", "<c-j>", tsj.toggle)

			vim.cmd.packadd 'vimplugin-sibling-swap.nvim'
			local ss = require('sibling-swap')
			ss.setup {
				use_default_keymaps = false,
			}
			-- Mapping is <c-.> due to a kitty/tmux conflict, we remap <c-.> to <a-.>
			vim.keymap.set("n", "<A-.>"     , ss.swap_with_right)
			vim.keymap.set("n", "<A-,>"     , ss.swap_with_left)
			vim.keymap.set("n", "<leader>." , ss.swap_with_right_with_opp)
			vim.keymap.set("n", "<leader>," , ss.swap_with_left_with_opp)

			vim.cmd.packadd 'iswap.nvim'
			require('iswap').setup {
				hl_flash = 'DiffAdd',
				autoswap = true,
				flash_style = 'simultaneous',
				hl_snipe = 'WarningMsg',
			}
			vim.keymap.set("n", "<C-s>", "<cmd>ISwap<cr>")
			vim.keymap.set("v", "<C-s>", "<cmd>ISwapWith<cr>")
		end,
	})
end

-- ==========================[ Improves Neovim UI ]==============================
-- Plugins that provide a nicer UI to interact with neovim builtins

if nixCats('builtin') and nixCats('ui') then
	require('mini.indentscope').setup {
		draw = {
			animation = require('mini.indentscope').gen_animation.none()
		},
		symbol = string.sub(vim.opt.listchars:get()["tab"], 1, 1),
	}
	vim.api.nvim_create_autocmd({'ColorScheme', 'UIEnter'}, {
		callback = function()
			vim.cmd [[
			highlight! link MiniIndentscopeSymbol Comment
			]]
		end
	})
	require("mini.cursorword").setup()
end

if nixCats('builtin') and nixCats('ui') then
	vim.api.nvim_create_autocmd("BufReadPre", {
		callback = function()
			vim.cmd.packadd 'nvim-origami'
			require('origami').setup {}
			vim.opt.foldlevelstart = 99
		end
	})
end

-----------------------------------[ Hover ]------------------------------------
if nixCats('ui') then
	require('hover').config {
		providers = {
			'hover.providers.fold_preview',
			'hover.providers.diagnostic',
			'hover.providers.lsp',
			'hover.providers.dap',
			'hover.providers.gh',
			'hover.providers.gh_user',
		},
		preview_window = true,
	}
	-- Setup keymaps
	vim.keymap.set('n', 'K', function()
		require('hover').open()
	end, { desc = 'hover.nvim (open)' })

	vim.keymap.set('n', 'gK', function()
		require('hover').enter()
	end, { desc = 'hover.nvim (enter)' })
end

-----------------------------------[ Marks ]------------------------------------
if nixCats('ui') then
	require('marks').setup {}
end

---------------------------------[ Registers ]----------------------------------

-- ========================[ add "Missing" features ]===========================
-- Those plugins ADD features to neovim, like a integration with fzf,
-- file manager, ect. But the purpose should still be about programmation and/or
-- text/code editing

-----------------------------------[ Files ]------------------------------------
require('mini.files').setup {}
vim.keymap.set('n', '<leader>o', MiniFiles.open)

----------------------------------[ Fzf Lua ]-----------------------------------
if nixCats('fzflua') then
	require('lze').load {
		{
			"fzf-lua",
			event = "DeferredUIEnter",
			after = function()
				require('fzf-lua').setup {
					ui_select = true,
					keymap = {
						fzf = {
							[ "ctrl-q" ] = "select-all+accept",
						},
					},
					files = {
						cwd_prompt = false,
						path_shorten = 1,
						no_ignore = false,
					},
				}

				-- Find stuff
				local maps = {
					{"<leader><leader>", FzfLua.builtin},
					{"<leader>ff", FzfLua.files},
					{"<leader>fF", FzfLua.live_grep_native},
					{"<leader>f/", FzfLua.blines},
					{"<leader>fb", FzfLua.buffers},
					{"<leader>fo", FzfLua.oldfiles},
					{"<leader>fq", FzfLua.quickfix},
					{"<leader>fQ", FzfLua.loclist},
					{"<leader>ft", FzfLua.tags},
					-- usefull for neovim
					{"<leader>fh", FzfLua.help_tags},
					{"<leader>fk", FzfLua.manpages},
					{"<leader>fm", FzfLua.marks},
					{"m/", FzfLua.marks},

					{"z=", FzfLua.spell_suggest},
					-- i_<c-something> to live grep word
					-- NOTE:
					-- - plenty of git utilities
					--
				}

				if nixCats('dap') then
					require('dap-view').setup {}
				end

				if nixCats('lsp') then
					vim.keymap.set("n", "gpr", function()
						FzfLua.lsp_references {
							actions = {
								["enter"] = function(sel, o)
									for _,s in pairs(sel) do
										local file = require('fzf-lua.path').entry_to_file(s, o)
										vim.cmd(string.format("pedit +%d %s", file.line, file.path or file.uri))
									end
								end
							},
						}
					end)
					vim.keymap.set("n", "gpi", function()
						FzfLua.lsp_implementations {
							actions = {
								["enter"] = function(sel, o)
									for _,s in pairs(sel) do
										local file = require('fzf-lua.path').entry_to_file(s, o)
										vim.cmd(string.format("pedit +%d %s", file.line, file.path or file.uri))
									end
								end
							},
						}
					end)
					vim.keymap.set({"n",  "v"},  "gra", FzfLua.lsp_code_actions)
					vim.keymap.set({"n"}, "gri", FzfLua.lsp_implementations)
					vim.keymap.set({"n"}, "grr", FzfLua.lsp_references)
					vim.keymap.set({"n"}, "grt", FzfLua.lsp_typedefs)
					vim.keymap.set({"n"}, "gO",  FzfLua.lsp_document_symbols)
					vim.keymap.set({"n"}, "gd",  FzfLua.lsp_definitions)
				end

				for _, v in pairs(maps) do
					local key = v[1]
					local action = v[2]

					vim.keymap.set("n", key, action)
				end

			end,
		}
	}

	-- See https://github.com/junegunn/fzf/issues/1213 for frecency
elseif nixCats('builtin') then
	require('mini.pick').setup {
		mappings = {
			choose_marked = '<C-q>', -- send selected to qflist
			mark = '<Tab>',
			mark_all = '<S-Tab>',
			toggle_preview = '<C-p>',
		}
	}
	require('mini.extra').setup {}
	vim.keymap.set('n', "<leader><leader>", MiniPick.builtin.resume)
	vim.keymap.set('n', "<leader>ff",       MiniPick.builtin.files)
	vim.keymap.set('n', "<leader>fF",       MiniPick.builtin.grep_live)
	vim.keymap.set('n', "<leader>f/",       MiniExtra.pickers.buf_lines)
	vim.keymap.set('n', "<leader>fb",       MiniPick.builtin.buffers)
	vim.keymap.set('n', "<leader>fo",       MiniExtra.pickers.oldfiles)
	vim.keymap.set('n', "<leader>fh",       MiniPick.builtin.help)
	vim.keymap.set('n', "<leader>fk",       MiniExtra.pickers.manpages)
	vim.keymap.set('n', "z=",               MiniExtra.pickers.spellsuggest)
	vim.keymap.set('n', "m/",               MiniExtra.pickers.marks)
end

------------------------------------[ Git ]-------------------------------------
if nixCats('git') then
	vim.keymap.set('n', '<leader>G', '<cmd>tab Git<cr>')
	require('gitsigns').setup {
		-- we want gitsigns to always on the leftmost sign
		sign_priority = 50,
		signs = {
			add          = { show_count = true},
			change       = { show_count = true},
			delete       = { show_count = true},
			topdelete    = { show_count = true},
			changedelete = { show_count = true},
			untracked    = { show_count = true},
		},
	}
	local signs = require 'gitsigns'

	vim.keymap.set("n", "<leader>gg", function() signs.setqflist('all') end)
	vim.keymap.set("n", "]h",         function() signs.nav_hunk('next') end)
	vim.keymap.set("n", "[h",         function() signs.nav_hunk('prev') end)
	vim.keymap.set("n", "<leader>hs", function() signs.stage_hunk()     end)
	vim.keymap.set("n", "<leader>hr", function() signs.reset_hunk()     end)
	vim.keymap.set("n", "<leader>hh", function() signs.stage_hunk()     end)
	vim.keymap.set("n", "<leader>hb", function() signs.blame_line()     end)
	vim.keymap.set("n", "<leaedr>hB", function() signs.blame()          end)

	if nixCats('fzflua') then
		vim.keymap.set("n", "<leader>hg", function() FzfLua.git_bcommits {
			actions = { ["enter"] = function(sel) signs.diffthis(sel[2]) end },
		}end)
	end
	require('lze').load {{
		'codediff.nvim',
		cmd = { "CodeDiff" },
		after = function()
			require('codediff').setup {}
		end,
	}}
	-- require('gitgraph').setup {}
end

-- QuickFix list
vim.cmd.packadd "cfilter"

-- ##############################[ Eye Candy ]##################################
if nixCats('eyecandy') and nixCats('lsp') then
	require('lze').load {{
		'icons',
		event = "DeferredUIEnter",
		after = function()
			require('mini.icons').setup {}
			MiniIcons.mock_nvim_web_devicons()
			require('lspkind').init {}

			local hipatterns = require('mini.hipatterns')
			require('mini.hipatterns').setup {
				highlighters = {
					fixme = { pattern = 'FIXME', group = 'MiniHipatternsFixme' },
					hack  = { pattern = 'HACK',  group = 'MiniHipatternsHack'  },
					todo  = { pattern = 'TODO',  group = 'MiniHipatternsTodo'  },
					note  = { pattern = 'NOTE',  group = 'MiniHipatternsNote'  },
					hex_color = hipatterns.gen_highlighter.hex_color(),
				}
			}
		end
	}}
	vim.api.nvim_create_autocmd('LspAttach', {
		group = vim.api.nvim_create_augroup('LspAttach_Signature', {}),
		callback = function()
			vim.cmd.packadd 'lsp_signature.nvim'
			require('lsp_signature').setup {
				floating_window = false,
				hint_prefix = {
					above = "↙ ",  -- when the hint is on the line above the current line
					current = "← ",  -- when the hint is on the same line
					below = "↖ "  -- when the hint is on the line below the current line
				},
				handler_opts = {
					border = "none",
				},
			}
		end,
	})
end
