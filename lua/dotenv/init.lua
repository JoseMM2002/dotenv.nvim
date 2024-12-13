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
	local values = vim.split(content, "\n")
	local out = {}
	for _, pair in pairs(values) do
		pair = vim.trim(pair)
		if not vim.startswith(pair, "#") and pair ~= "" then
			local splitted = vim.split(pair, "=")
			if #splitted > 1 then
				local key = splitted[1]
				local v = {}
				for i = 2, #splitted, 1 do
					local k = vim.trim(splitted[i])
					if k ~= "" then
						table.insert(v, splitted[i])
					end
				end
				if #v > 0 then
					local value = table.concat(v, "=")
					value, _ = string.gsub(value, '"', "")
					vim.env[key] = value
					out[key] = value
				end
			end
		end
	end
	return out
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

local function execute_reload(opts)
	local env_path = opts.env_path or ".env"
	_G.env_vars = load_env(env_path)
	vim.notify("Env vars reloaded", vim.log.levels.INFO)
end

function M.setup(opts)
	opts = opts or {}
	local env_path = opts.env_path or ".env"
	_G.env_vars = load_env(env_path)

	vim.api.nvim_create_user_command("Env", function(opts)
		execute_reload(opts)
	end, { nargs = 1, complete = "file" })
end

function M.get_env_vars()
	return _G.env_vars
end

function M.get_env_var(key)
	return _G.env_vars[key]
end

return M
