-- Auto-start remote server on .nvim socket
local M = {}

local socket_path = ".nvim.socket"

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

function M.get_socket_path()
  return socket_path
end

function M.setup(opts)
    opts = opts or {}
    socket_path = opts.socket or socket_path

    if not server_already_running() and not socket_exists() then
        local address = vim.fn.serverstart(socket_path)
        if address then
            vim.notify("Neovim server started on: " .. address, vim.log.levels.DEBUG)
        else
            vim.notify("Failed to start Neovim server", vim.log.levels.ERROR)
        end
    end
end

return M
