local M = {}

_G.env_vars = {}

local function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	else
		return false
	end
end

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	return content
end

local function parse_env(content)
	local env_vars = {}
	for line in content:gmatch("[^\r\n]+") do
		local key, value = line:match("^(%w+)%s*=%s*(.+)$")
		if key and value then
			env_vars[key] = value
		end
	end
	return env_vars
end

local function load_env(path)
	if not file_exists(path) then
		vim.notify(".env file not found at: " .. path, vim.log.levels.WARN)
		return {}
	end
	local content = read_file(path)
	if not content then
		vim.notify("Failed to read .env file at: " .. path, vim.log.levels.ERROR)
		return {}
	end
	return parse_env(content)
end

function M.setup(opts)
	opts = opts or {}
	local env_path = opts.env_path or ".env"
	_G.env_vars = load_env(env_path)
	vim.notify(".env file loaded from: " .. env_path, vim.log.levels.INFO)
end

function M.get_env_vars()
	return _G.env_vars
end

return M
