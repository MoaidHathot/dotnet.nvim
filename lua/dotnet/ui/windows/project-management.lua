local window_utils = require('dotnet.ui.windows.window-utils')
local ui_utils = require('dotnet.ui.ui-utils')
local telescope_utils = require('telescope.previewers.utils')
local dotnet_utils = require('dotnet.utils.dotnet-utils')
local path_utils = require('dotnet.utils.path-utils')

local M = {}

local _extract_project_template_from_cli_result = function(entry)
	local captures = dotnet_utils.get_tokens_split_by_whitespace(entry)

	local result = {
		template_name = captures[1],
		short_name = captures[2],
		language = captures[3],
	}

	local continue_index = 4
	if #captures < 6 or captures[6] == '' then
		result.language = ''
		continue_index = 3
	end

	result.type = captures[continue_index]

	if #captures < 5 or captures[5] == '' then
		result.type = ''
		continue_index = 2
	end

	result.author = captures[continue_index + 1]
	result.tags = captures[continue_index + 2] or ""
	return result
end

M.show_project_creation_window = function(user_opts)
	local opts = {
		telescope = window_utils.create_telescope_options(),
		prompt_title = "Select Project Template",
		previewer = {
			title = "Template Explorer",
			define_preview = function(self, entry)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, vim.tbl_flatten(
					{
						"# " .. "Template Name:",
						'\t' .. (entry.template_name or ""),
						"# " .. "Short Name:",
						'\t' .. (entry.short_name or ""),
						"# " .. "Languages:",
						'\t' .. (entry.language or ""),
						'# ' .. "Author:",
						'\t' .. (entry.author or ""),
						"# " .. "Tags:",
						'\t' .. (entry.tags or ""),
						"# " .. "Type:",
						'\t' .. (entry.type or ""),
					}
				))

				telescope_utils.highlighter(self.state.bufnr, "markdown")
			end
		},
		finder = {
			command_generator = function()
				return {
					'dotnet', 'new', 'list', '--columns-all'
				}
			end,
			entry_maker = function(entry)
				if string.match(entry, "---") or entry == '' or entry == nil or entry == "These templates matched your input: " or string.match(entry, "Template Name") then
					return
				end

				local captures = _extract_project_template_from_cli_result(entry)

				local template_name = captures.template_name
				local short_name = captures.short_name
				local language = captures.language
				local type = captures.type
				local author = captures.author
				local tags = captures.tags

				tags = tags or ''
				language = language or ''
				short_name = short_name or ''
				type = type or ''
				author = author or ''

				return {
					value = entry,
					display = template_name,
					ordinal = entry .. " " .. template_name .. " " .. short_name .. " " .. language .. " " .. tags,
					template_name = template_name,
					short_name = short_name,
					language = language,
					type = type,
					author = author,
					tags = tags,
				}
			end
		},
		attach_mappings = function(_, selection)
			local name = vim.fn.input("Name with path: ")

			name = string.gsub(name, "\\", "/")

			local extracted_names = path_utils.get_project_name_and_directory(name)
			local output = ''

			if extracted_names.project_directory ~= nil and extracted_names.project_directory ~= '' then
				output = ' -o ' .. extracted_names.project_directory
				if selection.type == 'project' then
					output = output .. '/' .. extracted_names.project_name
				end
				name = extracted_names.project_name
			end

			local template_name = string.match(selection.short_name, "([^,]+)")

			local name_arguments = ''
			if name ~= nil and name ~= '' then
				name_arguments = ' -n ' .. name
			end

			local command = "!dotnet new " .. template_name .. name_arguments .. output
			vim.cmd(command)
		end
	}

	ui_utils.open_selection_window(opts)
end


return M
