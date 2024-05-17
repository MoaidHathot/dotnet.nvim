local M = {}

M.open_add_project_reference_window = function(opts)
	require('lua.dotnet.ui.windows.project-references').open_add_project_reference_window()
end

M.open_remove_project_reference_window = function(opts)
	require('lua.dotnet.ui.windows.project-references').open_remove_project_reference_window()
end

M.open_project_creation_window = function(opts)
	require('lua.dotnet.ui.windows.project-management').show_project_creation_window()
end

M.open_add_package_window = function(opts)
	require('lua.dotnet.ui.windows.nuget-reference').open_add_package_window()
end

M.open_remove_package_window = function(opts)
	require('lua.dotnet.ui.windows.nuget-reference').open_remove_package_window()
end

return M
