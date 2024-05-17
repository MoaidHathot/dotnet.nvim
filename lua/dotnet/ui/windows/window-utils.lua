local nvim_utils = require ('lua.dotnet.utils.nvim-utils')
local telescope_utils = require('telescope.previewers.utils')
local ui_utils = require('lua.dotnet.ui.ui-utils')

local M = { }

M.create_telescope_options = function()
	return {
		layout_strategy = 'vertical',
		layout_config = {
			width = 0.3,
		}
	}
end


M.open_project_selection_window = function(selection_opts)
	local result_filter = selection_opts.result_filter or function(_, _)
		return true
	end
	local command_generator = selection_opts.command_generator or function(_)
		return { 'fd', '-e', 'csproj', '--type', 'f' }
	end
	local entry_maker = selection_opts.entry_maker or function(entry)
		if entry then
			return {
				value = entry,
				display = entry,
				ordinal = entry,
			}
		end
	end
	local opts = {
		telescope = M.create_telescope_options(),
		prompt_title = selection_opts.prompt_title or "Select Project",
		previewer = {
			title = selection_opts.title or "Project Explorer",
			define_preview = function(self, entry)
				local path = entry.value
				if path and entry.path_prefix then
					path = entry.path_prefix .. '/' .. path
				end
				local success, error = pcall(function()
					nvim_utils.load_file_into_buffer(path, self.state.bufnr)
					telescope_utils.highlighter(self.state.bufnr, "xml")
				end)

				if not success then
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, vim.tbl_flatten(
						{
							"Error loading file: " .. entry.value,
							error
						}
					))
				end
			end
		},
		finder = {
			command_generator = function()
				return command_generator(selection_opts)
			end,
			entry_maker = function(entry)
				if entry then
					local prepared_entry = entry_maker(entry)
					prepared_entry.path_prefix = selection_opts.path_prefix
					if result_filter(selection_opts, prepared_entry) then
						return prepared_entry
					end
				end
			end
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


return M
