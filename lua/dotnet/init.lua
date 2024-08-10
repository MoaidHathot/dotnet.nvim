local M = {}

M.setup = function(opts)
	M.opts = opts
end

--Useful for debugging
-- package.loaded['lua.dotnet'] = nil
-- package.loaded['lua.dotnet.dotnet'] = nil
-- package.loaded['lua.dotnet.ui.ui'] = nil
-- package.loaded['lua.dotnet.ui.windows.project-references'] = nil
-- package.loaded['lua.dotnet.ui.windows.project-management'] = nil
-- package.loaded['lua.dotnet.ui.windows.nuget-reference'] = nil
-- package.loaded['lua.dotnet.ui.windows.window-utils'] = nil
-- package.loaded['lua.dotnet.utils.nvim-utils'] = nil
-- package.loaded['lua.dotnet.utils.path-utils'] = nil
-- package.loaded['lua.dotnet.utils.dotnet-utils'] = nil
-- package.loaded['lua.dotnet.ui.ui-utils'] = nil

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
	function(opts)
		local action = custom_dotnet_completions(opts.name .. ' ' .. opts.args, true)
		if type(action) == 'function' then
			action(M.opts)
		end
	end,
	{
		nargs = '?',
		complete = function(_, cmdline, _) return custom_dotnet_completions(cmdline) end,
	}
)

return M
