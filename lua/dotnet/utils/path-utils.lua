local log = require("plenary.log"):new()
local M = {}
local scan = require "plenary.scandir"
function M.tbl_contains_pattern(t, pattern)
  vim.validate { t = { t, "t" } }
  for _, v in ipairs(t) do
    if string.match(v, pattern) then
      return true
    end
  end
  return false
end
function M.cwd_contains_pattern(pattern)
  local dir = scan.scan_dir(".", { hidden = true, depth = 1 })
  local result = M.tbl_contains_pattern(dir, pattern)
  return result
end
function M.is_directory(path)
  if vim.fn.isdirectory(path) == 1 then
    return true
  else
    return false
  end
end
function M.get_last_path_part(path)
	local part = nil
	for current_match in string.gmatch(path, "[^/\\]+") do
		part = current_match
	end
	return part
end
function M.get_parent_directory(path)
  local directory
  local split = path:match "/[^/]*$"
  if split ~= nil then
    directory = path:gsub(split, "")
  end
  return directory
end

function M.get_file_path_namespace(file_path)
  local path = file_path
  local path_tmp
  local cwd = vim.fn.getcwd()
  local project
  local project_parent
  local dir

  path = M.get_parent_directory(path)
  path_tmp = path

  -- Get project path
  if file_path ~= nil then
    while true do
      dir = scan.scan_dir(path, { hidden = true, depth = 1 })

      if M.tbl_contains_pattern(dir, ".*%.[fc]sproj") then
        project = path
        break
      end

      if path == cwd then
        return cwd
      end

      path = M.get_parent_directory(path)
    end

    if project and path_tmp then
      project_parent = M.get_parent_directory(project)

      return path_tmp:gsub(project_parent, ""):sub(2):gsub("/", ".")
    else
      log.error("Failed to find parent project")
      return cwd
    end
  else
    log.error("Failed to find parent project")
    return cwd
  end
end

function M.get_projects()
  local project_paths = scan.scan_dir(vim.fn.getcwd(), { search_pattern = ".*%.[fc]sproj$" })
  return project_paths
end

M.get_project_name_and_directory = function(name_with_path)
	name_with_path = string.gsub(name_with_path, "\\", "/")
	local directory = string.match(name_with_path, "(.+/)[^/\\]+")
	if directory == nil or directory == '' or directory == './' then
		directory = ''
	end
	local name = string.gsub(name_with_path, directory, '')
	return {
		project_name = name,
		project_directory = directory,
	}
end

return M
