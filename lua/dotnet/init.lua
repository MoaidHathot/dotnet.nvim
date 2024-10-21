--Useful for debugging
package.loaded['dotnet'] = nil
package.loaded['dotnet.dotnet'] = nil
package.loaded['dotnet.ui.ui'] = nil
package.loaded['dotnet.ui.windows.project-references'] = nil
package.loaded['dotnet.ui.windows.project-management'] = nil
package.loaded['dotnet.ui.windows.nuget-reference'] = nil
package.loaded['dotnet.ui.windows.window-utils'] = nil
package.loaded['dotnet.utils.nvim-utils'] = nil
package.loaded['dotnet.utils.path-utils'] = nil
package.loaded['dotnet.utils.dotnet-utils'] = nil
package.loaded['dotnet.utils.telescope-utils'] = nil
package.loaded['dotnet.ui.ui-utils'] = nil

local M = {
	opts = {
		bootstrap = {
			auto_bootstrap = true,
		},
		project_selection = {
			path_display = 'filename_first', -- filename_first, tail
		}
	}
}

local function _process_user_opts(opts)

	require('dotnet.utils.nvim-utils').merge_tables(M.opts, opts or {})

	return M.opts
end

M.setup = function(opts)

	M.opts = _process_user_opts(opts)

	local dotnet = require('dotnet.dotnet')

	local completions = {
		DotnetUI = {
			new_item = dotnet.open_project_creation_window,
			project = {
				reference = {
					add = dotnet.open_add_project_reference_window,
					remove = dotnet.open_remove_project_reference_window,
				},
				package = {

					add = dotnet.open_add_package_window,
					remove = dotnet.open_remove_package_window,
				}
			},
			file = {
				bootstrap = dotnet.bootstrap_new_csharp_file,
			}
		}
	}

	local function split_by_whitespace(input)
		local words = {}
		for word in string.gmatch(input, "%S+") do
			table.insert(words, word)
		end
		return words
	end

	local function get_table_properties(tbl, include_functions)
		if include_functions and type(tbl) == 'function' then
			return tbl
		end
		if tbl == nil or type(tbl) == 'function' then
			return {}
		end
		local properties = {}
		for key, value in pairs(tbl) do
			local add = key
			if type(value) ~= 'table' and type(value) ~= 'function' then
				add = value
			end
			table.insert(properties, add)
		end
		return properties
	end

	local function custom_dotnet_completions(cmdline, include_functions)
		local results = {}
		local words = split_by_whitespace(cmdline)
		local cmp = completions
		for _, value in ipairs(words) do
			if cmp then
				if include_functions and type(cmp) == 'function' then
					return cmp
				end
				cmp = cmp[value]
				results = get_table_properties(cmp, include_functions)
			end
		end
		return results
	end

	vim.api.nvim_create_user_command(
		'DotnetUI',
		function(options)
			local action = custom_dotnet_completions(options.name .. ' ' .. options.args, true)
			if type(action) == 'function' then
				action(M.opts)
			end
		end,
		{
			nargs = '?',
			complete = function(_, cmdline, _) return custom_dotnet_completions(cmdline) end,
		}
	)

	if M.opts.bootstrap.auto_bootstrap then
		vim.api.nvim_create_autocmd("BufReadPost", {
			pattern = { "*.cs" },
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				local line_count = vim.api.nvim_buf_line_count(buf)

				if line_count == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
					dotnet.bootstrap_new_csharp_file()
				end
			end,
		})
	end

end

return M
