local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values;
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local function create_finder_options(opts)
	if opts.finder.command_generator then
		return function()
			return finders.new_async_job({
				command_generator = opts.finder.command_generator,
				entry_maker = opts.finder.entry_maker,
			})
		end
	end

	if opts.finder.fn then
		return function()
			local prompt = opts.prompt
			return finders.new_dynamic({
				fn = opts.finder.fn,
				entry_maker = opts.finder.entry_maker,
			})
		end
	end

	error("finder is nil")
end

M.open_selection_window = function(opts)
	local preview = opts.previewer or { title = "Preview" }
	local finder = create_finder_options(opts)

	local picker = pickers.new(opts.telescope or {}, {
		prompt_title = opts.prompt_title or "Select an item",
		finder = finder(),
		previewer = preview.previewer_override or previewers.new_buffer_previewer({
			title = preview.title,
			define_preview = preview.define_preview,
		}),
		sorter = config.generic_sorter(opts),
		attach_mappings = function(bufnr)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(bufnr)

				if not opts.attach_mappings then
					return;
				end

				local response = opts.attach_mappings(opts, selection)

				if response and response.continuation then
					local response_opts = response.response_opts or opts
					response.continuation(response_opts)
				end
			end)

			return true
		end
	})

	picker:find()
end

return M

