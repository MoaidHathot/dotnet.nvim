local window_utils = require('dotnet.ui.windows.window-utils')
local nvim_utils = require('dotnet.utils.nvim-utils')
local ui_utils = require('dotnet.ui.ui-utils')
local telescope_utils = require('telescope.previewers.utils')
local plenary = require('plenary')

local M = {}

local _make_nuget_search_command = function(opts)
	opts = opts or {}
	local name = opts.package_name
	if opts.prompt ~= nil and opts.prompt ~= '' then
		name = opts.prompt
	end

	name = name or ''
	name = string.gsub(name, " ", "+")

	--Todo: Add support for other sources
	local url = 'https://azuresearch-ussc.nuget.org/query?q=' .. name
	local job_opts = {
		command = "curl",
		args = { url },
	}

	local job = plenary.job:new(job_opts):sync()
	local result = vim.json.decode(job[1])

	local packages = result

	local entries = {}
	for index, package in pairs(packages.data) do
		entries[index] = package
	end

	return entries
end


local _nuget_explorer_live_preview_define_perview = function(self, entry)
	local authors = {}
	for _, v in pairs(entry.value.authors) do
		if v then
			table.insert(authors, v)
		end
	end

	local versions = {}
	for _, v in pairs(entry.value.versions) do
		if v then
			table.insert(versions, v.version)
		end
	end

	local bufLines = {

		"# " .. entry.value.title,
		"# Latest Version:",
		entry.value.version,
		"# Description:",
	}

	for _, v in pairs(nvim_utils.remove_new_lines(entry.value.description)) do
		table.insert(bufLines, v)
	end

	table.insert(bufLines, "# Downloads:")
	table.insert(bufLines, entry.value.totalDownloads .. '')

	table.insert(bufLines, "# Authors:")

	for _, v in pairs(authors) do
		table.insert(bufLines, '    * ' .. v)
	end

	table.insert(bufLines, "# Versions:")
	for _, v in pairs(versions) do
		table.insert(bufLines, '    * ' .. v)
	end

	vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, bufLines)
	telescope_utils.highlighter(self.state.bufnr, "markdown")
end

local _show_nuget_explorer_selection_window = function(selection_opts)
	local command_generator = selection_opts.command_generator
	local fn = command_generator or selection_opts.fn or function(prompt)
		return _make_nuget_search_command({ package_name = prompt })
	end
	local entry_maker = selection_opts.entry_maker or function(entry)
		if entry then
			return {
				value = entry,
				display = entry.title,
				ordinal = entry.title
			}
		end
	end

	local opts = {
		telescope = window_utils.create_telescope_options(),
		prompt_title = selection_opts.prompt_title or "Select Nuget Package",
		previewer = {
			title = selection_opts.title or "Nuget Explorer",
			define_preview = function(self, entry)
				_nuget_explorer_live_preview_define_perview(self, entry)
		end,
		},
		finder = {
			fn = fn,
			command_generator = command_generator,
			entry_maker = entry_maker,
		},
		attach_mappings = function(_, selection)
			if selection_opts == nil or selection_opts.attach_mappings == nil then
				return selection
			end

			return selection_opts.attach_mappings(selection_opts, selection)
		end
	}

	ui_utils.open_selection_window(opts)
end

local _open_project_package_management_window = function(opts)
	local action = opts.action or 'add'

	local first_selection_title = opts.first_prompt_title or ("Select a project to " .. action .. " package to")
	local second_selection_title = opts.second_prompt_title or ("Select a package to " .. action)

	local source_selection_opt = {
		prompt_title = first_selection_title,
		attach_mappings = function(_, selection)
			local target_selection_opt = {
				prompt_title = second_selection_title,
				attach_mappings = function(response_opts, package_to_add)
					local cmd = '!dotnet ' ..
					action .. ' ' .. response_opts.add_to_project.value .. ' package ' .. package_to_add.value.id
					vim.cmd(cmd)
				end,
				add_to_project = selection,
				command_generator = opts.command_generator,
				entry_maker = opts.entry_maker,
			}

			return {
				response_opts = target_selection_opt,
				continuation = function(response_opts)
					return _show_nuget_explorer_selection_window(response_opts)
				end,
			}
		end,
		entry_maker = function(entry)
			if entry then
				return {
					value = entry,
					display = entry,
					ordinal = entry,
				}
			end
		end
	}

	window_utils.open_project_selection_window(source_selection_opt)
end


M.open_add_package_window = function()
	_open_project_package_management_window({
		action = 'add',
		first_prompt_title = 'Select a project to add package to',
		second_prompt_title = 'Select a package to add'
	})
end

M.open_remove_package_window = function()
	_open_project_package_management_window({
		action = 'remove',
		first_prompt_title = 'Select a project to remove package from',
		second_prompt_title = 'Select a package to remvoe',
	})
end


return M
