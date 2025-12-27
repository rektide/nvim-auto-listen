-- Auto-start remote server on .nvim socket
local M = {}

local socket_path = ".nvim.socket"
local created_socket = false

local function parse_env_bool(value)
  if not value then
    return nil
  end
  value = value:lower()
  return value == "1" or value == "true" or value == "yes"
end

local function parse_env_array(value)
  if not value then
    return nil
  end
  if value == "" then
    return {}
  end
  local result = {}
  for item in value:gmatch("[^,]+") do
    table.insert(result, vim.trim(item))
  end
  return result
end

local function merge_with_env_vars(opts)
  local result = vim.deepcopy(opts or {})

  if result.socket == nil then
    result.socket = vim.env.NVIM_AUTO_SOCKET or vim.env.NVIM_AUTO_SOCKET_PATH or vim.env.NVIM_SOCKET_PATH
  end

  if result.socket_xdg_runtime == nil then
    result.socket_xdg_runtime = parse_env_bool(vim.env.NVIM_AUTO_LISTEN_XDG_RUNTIME)
  end

  if result.socket_named == nil then
    result.socket_named = vim.env.NVIM_AUTO_LISTEN_NAMED
  end

  if result.socket_hidden == nil then
    local env_val = vim.env.NVIM_AUTO_LISTEN_HIDDEN
    result.socket_hidden = parse_env_bool(env_val) or true
  end

  if result.autorun == nil then
    local env_val = vim.env.NVIM_AUTO_LISTEN_AUTORUN
    result.autorun = parse_env_bool(env_val) or true
  end

  if result.project_root == nil then
    local env_val = vim.env.NVIM_AUTO_LISTEN_PROJECT_ROOT
    result.project_root = parse_env_array(env_val) or { "README.md", "package.json", "Cargo.toml", "pyproject.toml" }
  end

  return result
end

local function find_project_root(opts)
  if not opts.project_root or #opts.project_root == 0 then
    return vim.loop.cwd()
  end

  local dir = vim.loop.cwd()

  while dir do
    for _, file in ipairs(opts.project_root) do
      local stat = vim.loop.fs_stat(dir .. "/" .. file)
      if stat and stat.type == "file" then
        return dir
      end
    end

    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end

  return vim.loop.cwd()
end

local function get_socket_path(opts)
  if opts.socket then
    return opts.socket
  end

  local base_dir
  if opts.socket_xdg_runtime then
    base_dir = vim.fn.stdpath("cache")
  else
    base_dir = find_project_root(opts)
    if base_dir ~= vim.loop.cwd() then
      vim.notify("Using project root: " .. base_dir, vim.log.levels.INFO)
    end
  end

  local basename = "nvim"

  if opts.socket_named then
    if opts.socket_named == true then
      local dirname = vim.fs.basename(vim.loop.cwd())
      basename = "nvim." .. dirname
    elseif type(opts.socket_named) == "string" then
      basename = "nvim." .. opts.socket_named
    end
  end

  local filename = opts.socket_hidden and ("." .. basename) or basename
  filename = filename .. ".socket"

  return base_dir .. "/" .. filename
end

local function server_already_running()
    -- Check if server is already listening
    local servers = vim.fn.serverlist()
    for _, server in ipairs(servers) do
        if server == socket_path then
            return true
        end
    end
    return false
end

local function socket_exists()
    local stat = vim.loop.fs_stat(socket_path)
    return stat ~= nil and stat.type == "socket"
end

local function cleanup_socket()
  if created_socket and socket_exists() then
    local ok, err = vim.loop.fs_unlink(socket_path)
    if ok then
      vim.notify("Cleaned up socket: " .. socket_path, vim.log.levels.INFO)
    else
      vim.notify("Failed to clean up socket: " .. (err or "unknown error"), vim.log.levels.WARN)
    end
  end
end

local function setup_autocmd()
  local group = vim.api.nvim_create_augroup("AutoListenCleanup", { clear = true })
  vim.api.nvim_create_autocmd("VimLeave", {
    group = group,
    callback = cleanup_socket,
    desc = "Clean up socket file on exit",
  })
end

function M.get_socket_path()
  return socket_path
end

function M.setup(opts)
    opts = merge_with_env_vars(opts or {})

    socket_path = get_socket_path(opts)

    setup_autocmd()

    if opts.autorun and not server_already_running() and not socket_exists() then
        local address = vim.fn.serverstart(socket_path)
        if address then
            created_socket = true
            vim.notify("Neovim server started on: " .. address, vim.log.levels.DEBUG)
        else
            vim.notify("Failed to start Neovim server", vim.log.levels.ERROR)
        end
    end
end

return M
