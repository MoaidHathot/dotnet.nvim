local M = {}

M.load_file_into_buffer = function(filepath, bufnr)
	local file = io.open(filepath, "r")
	if not file then
		error("Cannot open file: " .. filepath)
		return
	end

	local lines = {}
	for line in file:lines() do
		table.insert(lines, line)
	end
	file:close()

	if not vim.api.nvim_buf_is_loaded(bufnr) then
		vim.api.nvim_command('buffer ' .. bufnr)
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

M.remove_new_lines = function(text)
	local lines = {}
	for line in string.gmatch(text, "[^\n]+") do
		table.insert(lines, line)
	end

	return lines
end

M.merge_tables = function(t1, t2)
	for _, value in ipairs(t2) do
		table.insert(t1, value)
	end

	-- Merge dictionary part
	for key, value in pairs(t2) do
		if type(key) ~= "number" then
			t1[key] = value
		end
	end
end

return M
