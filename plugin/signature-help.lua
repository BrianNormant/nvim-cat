if nixCats('lsp') then
	-- Global state to track our signature help buffer
	local signature_help_bufnr = nil

	local function get_signature_help_lines()
	  local lines = {}

	  -- Make LSP request synchronously using vim.lsp.buf_request_all
	  local params = vim.lsp.util.make_position_params(0, 'utf-8')
	  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

	  -- Filter clients that support signatureHelp
	  local signature_clients = {}
	  for _, client in ipairs(clients) do
		if client.server_capabilities.signatureHelpProvider then
		  table.insert(signature_clients, client)
		end
	  end

	  if #signature_clients == 0 then
		return { "No LSP client supports signature help" }
	  end

	  -- Use the first client that supports signature help
	  local client = signature_clients[1]
	  local result = client.request_sync("textDocument/signatureHelp", params, 1000)

	  if not result or not result.result or not result.result.signatures then
		return { "No signature help available" }
	  end

	  local signatures = result.result.signatures
	  local active_signature = result.result.activeSignature or 0
	  local active_parameter = result.result.activeParameter or 0

	  -- Build signature help lines
	  if #signatures > 0 then
		-- Show all signatures with active one highlighted
		table.insert(lines, "Available signatures (" .. #signatures .. " total):")
		table.insert(lines, "")

		for i, sig in ipairs(signatures) do
		  -- Add signature label with active indicator
		  if i - 1 == active_signature then
			table.insert(lines, "➤ " .. sig.label)
		  else
			table.insert(lines, "  " .. sig.label)
		  end

		  -- Show parameters for all signatures
		  if sig.parameters and #sig.parameters > 0 then
			table.insert(lines, "")
			table.insert(lines, "  Parameters:")

			for j, param in ipairs(sig.parameters) do
			  -- Active parameter marker for active signature
			  local prefix = "    "
			  if i - 1 == active_signature and j - 1 == active_parameter then
				prefix = "  ▶ "
			  end

			  local param_label = param.label
			  if type(param_label) == "table" then
				-- Range format [start, end]
				param_label = string.sub(sig.label, param_label[1] + 1, param_label[2])
			  end

			  table.insert(lines, prefix .. j .. ". " .. param_label)

			  -- Add parameter documentation if available
			  if param.documentation then
				local doc = param.documentation
				local doc_text = type(doc) == "string" and doc or doc.value
				if doc_text then
				  for line in vim.gsplit(doc_text:gsub("\r", ""), "\n") do
					if #line > 0 then
					  table.insert(lines, "      " .. line)
					end
				  end
				end
			  end
			end
		  end

		  -- Signature documentation for all signatures
		  if sig.documentation then
			local doc = sig.documentation
			local doc_text = type(doc) == "string" and doc or doc.value
			if doc_text and #doc_text > 0 then
			  table.insert(lines, "")
			  table.insert(lines, "  Documentation:")
			  for line in vim.gsplit(doc_text:gsub("\r", ""), "\n") do
				if #line > 0 then
				  table.insert(lines, "    " .. line)
				end
			  end
			end
		  end

		  -- Add separator between signatures (except after last one)
		  if i < #signatures then
			table.insert(lines, "")
			table.insert(lines, string.rep("─", 60))
			table.insert(lines, "")
		  end
		end
	  end

	  if #lines == 0 then
		return { "No signature information available" }
	  end

	  return lines
	end

	local function toggle_signature_help()
	  -- Check if preview window is open in tabpage
	  local preview_win = nil
	  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_get_option_value('previewwindow', {win = win}) then
		  preview_win = win
		  break
		end
	  end

	  -- Get or create signature help lines
	  local lines = get_signature_help_lines()

	  if preview_win then
		-- Preview window exists; replace with signature help
		-- Create new buffer for signature help
		local new_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(new_buf, 0, -1, true, lines)
		vim.api.nvim_set_option_value('filetype',  'markdown', {buf = new_buf})
		vim.api.nvim_set_option_value('buftype',   'nofile',   {buf = new_buf})
		vim.api.nvim_set_option_value('bufhidden', 'wipe',     {buf = new_buf})

		-- Replace preview window buffer
		vim.api.nvim_win_set_buf(preview_win, new_buf)

		-- Update tracking
		signature_help_bufnr = new_buf
	  else
		-- No preview window, open one
		-- Create buffer for signature help
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
		vim.api.nvim_set_option_value('filetype',  'markdown', {buf = buf})
		vim.api.nvim_set_option_value('buftype',   'nofile',   {buf = buf})
		vim.api.nvim_set_option_value('bufhidden', 'wipe',     {buf = buf})

		-- Open preview window
		vim.cmd('pedit')

		-- Find the preview window and set our buffer
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		  if vim.api.nvim_get_option_value('previewwindow', {win = win}) then
			vim.api.nvim_win_set_buf(win, buf)
			vim.api.nvim_set_option_value('wrap',           true,  {win = win})
			vim.api.nvim_set_option_value('number',         false, {win = win})
			vim.api.nvim_set_option_value('relativenumber', false, {win = win})
			vim.api.nvim_set_option_value('cursorline',     false, {win = win})
			break
		  end
		end

		-- Update tracking
		signature_help_bufnr = buf
	  end
	end

	-- Set up key mapping
	vim.keymap.set({'i', 'n'}, '<c-s>', toggle_signature_help, {
	  desc = "Toggle LSP signature help in preview window",
	  noremap = true,
	  silent = true
	})

	-- Cleanup buffer when it's no longer needed
	vim.api.nvim_create_autocmd("BufWipeout", {
	  callback = function(args)
		if args.buf == signature_help_bufnr then
		  signature_help_bufnr = nil
		end
	  end
	})
end
