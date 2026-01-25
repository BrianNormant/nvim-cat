-- Preview window utilities with position tracking
local M = {}

-- State for preview window history with positions
local preview_history = {
  entries = {},  -- List of {bufnr, line, col} entries
  current_index = 0,  -- Current position in history
}

-- Function to open preview window with a specific buffer and position
M.open_preview_window = function(bufnr, line, col)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  line = line or 0  -- Default to first line
  col = col or 0    -- Default to first column

  -- Check if preview window already exists
  local preview_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_get_option_value('previewwindow', {win=win}) then
      preview_win = win
      break
    end
  end

  if preview_win then
    -- Preview window exists, set the buffer and position
    vim.api.nvim_win_set_buf(preview_win, bufnr)
    vim.api.nvim_win_set_cursor(preview_win, {line + 1, col})
  else
    -- No preview window, open one
    vim.cmd('pedit')

    -- Find the newly created preview window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_get_option_value('previewwindow', {win=win}) then
        preview_win = win
        break
      end
    end

    if preview_win then
      vim.api.nvim_win_set_buf(preview_win, bufnr)
      vim.api.nvim_win_set_cursor(preview_win, {line + 1, col})
    end
  end

  -- Set preview window options
  if preview_win then
    vim.api.nvim_set_option_value('wrap', true, {win=preview_win})
    vim.api.nvim_set_option_value('number', false, {win=preview_win})
    vim.api.nvim_set_option_value('relativenumber', false, {win=preview_win})
    vim.api.nvim_set_option_value('cursorline', false, {win=preview_win})

    -- Add to history
    M._add_to_history(bufnr, line, col)

    return preview_win
  end

  return false
end

-- Function to open preview window with common files
M.open_preview_with_common = function()
  -- Check if current window is empty
  local current_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
  local is_empty = #lines == 0 or (#lines == 1 and lines[1] == "")

  if not is_empty then
    -- Current window has content, preview current file at cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = cursor_pos[1] - 1
    local col = cursor_pos[2]
    return M.open_preview_window(current_buf, line, col)
  end

  -- Try common files in current directory
  local common_files = { 'README.md', '.gitignore', 'README.txt', 'README', 'LICENSE', 'CHANGELOG.md' }

  for _, file in ipairs(common_files) do
    local full_path = vim.fn.getcwd() .. '/' .. file
    if vim.fn.filereadable(full_path) == 1 then
      -- Load the file into a buffer
      local bufnr = vim.fn.bufadd(full_path)
      vim.fn.bufload(bufnr)
      return M.open_preview_window(bufnr, 0, 0)
    end
  end

  -- No common files found, fail silently
  return false
end

-- Internal function to add buffer position to history
M._add_to_history = function(bufnr, line, col)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  line = line or 0
  col = col or 0

  -- Clean invalid entries from history
  local valid_entries = {}
  for _, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      table.insert(valid_entries, entry)
    end
  end
  preview_history.entries = valid_entries

  -- Create new entry
  local new_entry = {
    bufnr = bufnr,
    line = line,
    col = col,
  }

  -- Check if this exact position is already at current index
  if preview_history.current_index > 0 and preview_history.current_index <= #preview_history.entries then
    local current_entry = preview_history.entries[preview_history.current_index]
    if current_entry and
       current_entry.bufnr == bufnr and
       current_entry.line == line and
       current_entry.col == col then
      return  -- Already at this exact position
    end
  end

  -- Add new entry to history
  table.insert(preview_history.entries, new_entry)
  preview_history.current_index = #preview_history.entries

  -- Limit history size
  local max_history = 100
  if #preview_history.entries > max_history then
    table.remove(preview_history.entries, 1)
    preview_history.current_index = preview_history.current_index - 1
  end
end

-- Function to navigate to previous buffer in preview history
M.preview_older = function()
  -- Clean invalid entries first
  local valid_entries = {}
  for _, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      table.insert(valid_entries, entry)
    end
  end
  preview_history.entries = valid_entries

  if #preview_history.entries == 0 then
    return false
  end

  if preview_history.current_index <= 1 then
    return false
  end

  preview_history.current_index = preview_history.current_index - 1
  local entry = preview_history.entries[preview_history.current_index]

  if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
    return M.open_preview_window(entry.bufnr, entry.line, entry.col)
  end

  return false
end

-- Function to navigate to next buffer in preview history
M.preview_newer = function()
  -- Clean invalid entries first
  local valid_entries = {}
  for _, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      table.insert(valid_entries, entry)
    end
  end
  preview_history.entries = valid_entries

  if #preview_history.entries == 0 then
    return false
  end

  if preview_history.current_index >= #preview_history.entries then
    return false
  end

  preview_history.current_index = preview_history.current_index + 1
  local entry = preview_history.entries[preview_history.current_index]

  if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
    return M.open_preview_window(entry.bufnr, entry.line, entry.col)
  end

  return false
end

-- Function to go to oldest entry in history
M.preview_oldest = function()
  -- Clean invalid entries first
  local valid_entries = {}
  for _, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      table.insert(valid_entries, entry)
    end
  end
  preview_history.entries = valid_entries

  if #preview_history.entries == 0 then
    return false
  end

  preview_history.current_index = 1
  local entry = preview_history.entries[1]

  if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
    return M.open_preview_window(entry.bufnr, entry.line, entry.col)
  end

  return false
end

-- Function to go to newest entry in history
M.preview_newest = function()
  -- Clean invalid entries first
  local valid_entries = {}
  for _, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      table.insert(valid_entries, entry)
    end
  end
  preview_history.entries = valid_entries

  if #preview_history.entries == 0 then
    return false
  end

  preview_history.current_index = #preview_history.entries
  local entry = preview_history.entries[preview_history.current_index]

  if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
    return M.open_preview_window(entry.bufnr, entry.line, entry.col)
  end

  return false
end

-- Function to clear preview history
M.clear_preview_history = function()
  preview_history.entries = {}
  preview_history.current_index = 0
end

-- Function to show preview history
M.show_preview_history = function()
  local lines = {}

  for i, entry in ipairs(preview_history.entries) do
    if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      local name = vim.api.nvim_buf_get_name(entry.bufnr)
      if name == "" then
        name = string.format("[Buffer %d]", entry.bufnr)
      else
        name = vim.fn.fnamemodify(name, ":.")
      end

      local marker = (i == preview_history.current_index) and "➤ " or "  "
      table.insert(lines, string.format("%s%s:%d:%d", marker, name, entry.line + 1, entry.col))
    end
  end

  if #lines == 0 then
    table.insert(lines, "(empty)")
  end

  -- Print to message area
  print("Preview history:")
  for _, line in ipairs(lines) do
    print(line)
  end
end

-- Set up autocmd to track preview window buffer and cursor changes
vim.api.nvim_create_autocmd({"BufEnter", "WinScrolled"}, {
  pattern = "*",
  callback = function(_)
	local wins = vim.api.nvim_tabpage_list_wins(0)
	for _,win in ipairs(wins) do
		if vim.api.nvim_get_option_value('previewwindow', {win=win}) then
			local bufnr = vim.api.nvim_win_get_buf(win)
			local cursor_pos = vim.api.nvim_win_get_cursor(win)
			local line = cursor_pos[1] - 1
			local col = cursor_pos[2]

			M._add_to_history(bufnr, line, col)
			return -- one preview per tabpage
		end
	end
  end,
})

-- Create user commands
vim.api.nvim_create_user_command("Pcommon", M.open_preview_with_common, {
  desc = "Open preview window with common files"
})

vim.api.nvim_create_user_command("Polder", M.preview_older, {
  desc = "Go to older preview in history"
})

vim.api.nvim_create_user_command("Pnewer", M.preview_newer, {
  desc = "Go to newer preview in history"
})

vim.api.nvim_create_user_command("Poldest", M.preview_oldest, {
  desc = "Go to oldest preview in history"
})

vim.api.nvim_create_user_command("Pnewest", M.preview_newest, {
  desc = "Go to newest preview in history"
})

vim.api.nvim_create_user_command("Phistory", M.show_preview_history, {
  desc = "Show preview window history"
})

vim.api.nvim_create_user_command("Pclear", M.clear_preview_history, {
  desc = "Clear preview window history"
})

-- Set up key mappings
vim.keymap.set('n', ']p', M.preview_newer,  { desc = "Next     preview history entry" })
vim.keymap.set('n', '[p', M.preview_older,  { desc = "Previous preview history entry" })
vim.keymap.set('n', ']P', M.preview_newest, { desc = "Newest   preview history entry" })
vim.keymap.set('n', '[P', M.preview_oldest, { desc = "Oldest   preview history entry" })

-- Export the module
return M
