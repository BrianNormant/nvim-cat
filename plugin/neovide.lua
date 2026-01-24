if vim.g.neovide then
	-- vim.o.guifont = "FiraCode_Nerd_Font_Ret,Flog_Symbols:h14";
	vim.o.guifont = "Victor_Mono,Flog_Symbols:h14";
	vim.g.neovide_floating_shadow = true;
	vim.g.neovide_floating_z_height = 1.0;
	vim.g.neovide_position_animation_length = 0.10;
	vim.g.neovide_scroll_animation_length = 0.1;
	vim.g.neovide_scroll_animation_far_lines = 9999;
	vim.g.neovide_hide_mouse_when_typing = true;
	vim.g.neovide_refresh_rate = 120;
	vim.g.neovide_cursor_animation_length = 0.13;
	vim.g.neovide_cursor_trail_size = 0.1;
	vim.g.neovide_cursor_animate_command_line = false
	vim.g.neovide_cursor_smooth_blink = true;
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
	vim.g.neovide_floating_border_radius = 0.5
	vim.keymap.set({ "n",   "v" },   "<C-+>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>")
	vim.keymap.set({ "n",   "v" },   "<C-_>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>")
	vim.keymap.set({ "n",   "v" },   "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")
	vim.keymap.set({ "v",   "v" },   "<C-S-C>", '"+y', { desc = "Copy system clipboard" })
	vim.keymap.set({ "n",   "v" },   "<C-S-V>", '"+p', { desc = "Paste system clipboard" })
	vim.env.NEOVIDE = 1
end
