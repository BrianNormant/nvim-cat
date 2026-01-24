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
			highlight! link Search PmenuSel
			highlight! link IncSearch PmenuSel
			highlight! link CurSearch FloatShadow
			highlight Substitute guibg=#545454
			]]
		end
	}
)
-- TODO: Find a better bg for the cursorline
if nixCats('melange') then
	vim.cmd [[colorscheme melange]]
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

-- ================================[ Extras ]===================================
-- stuff that are nice (event required imo) to have but require external plugins

----------------------------------[ UndoTree ]----------------------------------
vim.cmd.packadd "nvim.undotree"
vim.keymap.set("n", "<A-u>", "<cmd>Undotree<cr>")

------------------------------[ Highlight Search ]------------------------------
require("auto-hlsearch").setup({
	remap_keys = { "/", "?", "*", "#", "n", "N" },
	create_commands = true,
})
vim.cmd.packadd "nohlsearch"
vim.opt.updatetime = 2000

-- ===================[ Operators, Movement & textobject ]======================
-- leap
-- spider
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
	replace = { prefix = "sp", },
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

-- treesitter treesj

-- ==========================[ Replace Neovim UI ]==============================

------------------------------------[ Oil ]-------------------------------------
do
	require('oil').setup {}
	vim.keymap.set('n', '<leader>o', require('oil').open)
end

-----------------------------------[ Hover ]------------------------------------

-----------------------------------[ Marks ]------------------------------------
if nixCats('ui') then
	require('marks').setup {}
end

---------------------------------[ Registers ]----------------------------------

-- ========================[ add "Missing" features ]===========================

----------------------------------[ Fzf Lua ]-----------------------------------
do
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
	end
	
	if nixCats('lsp') then
	end

	for _, v in pairs(maps) do
		local key = v[1]
		local action = v[2]

		vim.keymap.set("n", key, action)
	end

	-- See https://github.com/junegunn/fzf/issues/1213 for frecency
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
	vim.keymap.set("n", "<leader>hg", function() FzfLua.git_bcommits {
		actions = { ["enter"] = function(sel) signs.diffthis(sel[2]) end },
	}end)
	-- require('codediff').setup {}
	-- require('gitgraph').setup {}
end

-- QuickFix list
vim.cmd.packadd "cfilter"

-- ##############################[ Eye Candy ]##################################
if nixCats('eyecandy') and nixCats('lsp') then
	require('mini.icons').setup {}
	MiniIcons.mock_nvim_web_devicons()
	require('lspkind').init {}

	-- require('lsp_signature').setup {
	-- 	hint_prefix = {
	-- 		hint_prefix = {
	-- 			above = "↙ ",  -- when the hint is on the line above the current line
	-- 			current = "← ",  -- when the hint is on the same line
	-- 			below = "↖ "  -- when the hint is on the line below the current line
	-- 		}
	-- }
end
