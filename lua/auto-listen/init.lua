-- Auto-start remote server on .nvim socket
local M = {}

local socket_path = ".nvim.socket"
local created_socket = false

local function get_socket_path(opts)
  if opts.socket then
    return opts.socket
  end

  local cwd = vim.loop.cwd()
  local basename = "nvim"

  if opts.socket_named then
    if opts.socket_named == true then
      local dirname = vim.fs.basename(cwd)
      basename = "nvim." .. dirname
    elseif type(opts.socket_named) == "string" then
      basename = "nvim." .. opts.socket_named
    end
  end

  local filename = opts.socket_hidden and ("." .. basename) or basename
  filename = filename .. ".socket"

  return cwd .. "/" .. filename
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
    opts = opts or {}
    opts.socket_hidden = opts.socket_hidden == nil and true or opts.socket_hidden
    opts.autorun = opts.autorun == nil and true or opts.autorun

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
