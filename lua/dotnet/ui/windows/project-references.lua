-- local window_utils = require('lua.dotnet.ui.windows.window-utils')
local window_utils = require('dotnet.ui.windows.window-utils')
local path_utils = require('dotnet.utils.path-utils')

local M = {}

local _open_project_reference_management_window = function(opts)
	local action = opts.action or 'add'

	local first_selection_title = opts.first_selection_title or ("Select a project to " .. action .. " reference to")
	local second_selection_title = opts.second_selection_title or "Select a project to reference"

	local second_result_filter = opts.second_result_filter or function(response_opts, entry)
		return entry.value ~= response_opts.add_to_project.value
	end

	local source_selection_opt = {
		prompt_title = first_selection_title,
		attach_mappings = function(_, selection)
			local target_selection_opt = {
				prompt_title = second_selection_title,
				attach_mappings = function(response_opts, project_to_add)
					local cmd = '!dotnet ' .. action .. ' ' .. response_opts.add_to_project.value .. ' reference ' .. project_to_add.value
					vim.cmd(cmd)
				end,
				command_generator = opts.second_command_generator,
				entry_maker = opts.second_entry_maker,
				result_filter = second_result_filter,
				add_to_project = selection,
			}

			if opts.action == 'remove' then
				target_selection_opt.path_prefix = path_utils.get_project_name_and_directory(selection.value).project_directory
			end

			return {
				response_opts = target_selection_opt,
				continuation = function(response_opts)
					return window_utils.open_project_selection_window(response_opts)
				end,
			}
		end
	}

	window_utils.open_project_selection_window(source_selection_opt)
end

M.open_add_project_reference_window = function()
	_open_project_reference_management_window({
		action = 'add',
		first_selection_title = 'Seledct a project to add reference to',
		second_selection_title = 'Select a project to reference'
	})
end

M.open_remove_project_reference_window = function()
	_open_project_reference_management_window({
		action = 'remove',
		first_selection_title = 'Seledct a project to remove reference from',
		second_selection_title = 'Select a referenced project',
		second_command_generator = function(opts)
			return {
				'dotnet', 'list', opts.add_to_project.value,  'reference'
			}
		end,
		second_result_filter = function(_, entry)
			if entry.value == 'Project reference(s)' then
				return false
			end

			if entry.value == '--------------------' then
				return false
			end

			if string.find(entry.value, 'There are no Project to Project references') then
				return false
			end

			return true
		end
	})
end


return M
