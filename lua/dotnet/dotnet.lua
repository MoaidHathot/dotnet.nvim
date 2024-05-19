local dotnet_utils = require('dotnet.utils.dotnet-utils')
local nvim_utils = require('dotnet.utils.nvim-utils')
local ui = require("dotnet.ui.ui")

local M = {}

M.bootstrap_new_csharp_file = function(opts)
	opts = opts or {}
	local names = dotnet_utils.get_curr_file_and_namespace()
	local buffer = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(buffer)

	local line_end = line_count
	local line_start = line_count

	if opts.append == false then
		line_start = 0
	end

	if not names or not names.namespace then
		return
	end

	local lines = {
		'namespace ' .. names.namespace .. ';',
		'',
		'public class ' .. names.file_name,
		'{',
		' ',
		'}',
	}
	vim.api.nvim_buf_set_lines(buffer, line_start, line_end, false, lines)
end

nvim_utils.merge_tables(M, ui)

return M
