local M = {}

function M.setup(config)
	print("Setup has been called")
end

function M.dotnet()
	local file = vim.fn.expand("%:p")
	print("Current file is " .. file)
end

function M.build()
	vim.cmd("vsplit | terminal")
	local command = ':call jobsend(b:terminal_job_id, "dir\\n")'
	vim.cmd(command)
end

vim.api.nvim_create_user_command("DotnetClearCache", function()
	package.loaded.dotnet = nil
	require('dotnet')
end, {})

function M.dotcache()

end

vim.api.nvim_create_user_command("Dotnet", M.dotnet, {})
-- vim.api.nvim_create_autocmd("CursorHold", { callback = M.dotnet })

-- todo
M.setup();

return M;
