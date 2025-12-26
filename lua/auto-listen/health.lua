local M = {}

local function check_plugin_loaded()
  local ok, _ = pcall(require, "auto-listen")
  if ok then
    vim.health.ok("auto-listen plugin loaded")
    return true
  else
    vim.health.error("auto-listen plugin not loaded")
    return false
  end
end

local function check_server_status()
  local ok, module = pcall(require, "auto-listen")
  if not ok then
    vim.health.info("Cannot check server status (module not loaded)")
    return
  end

  local servers = vim.fn.serverlist()
  local socket_path = module.get_socket_path and module.get_socket_path() or ".nvim.socket"

  local running = false
  for _, server in ipairs(servers) do
    if server == socket_path then
      running = true
      break
    end
  end

  if running then
    vim.health.ok("Neovim server running on: " .. socket_path)
  else
    local stat = vim.loop.fs_stat(socket_path)
    local exists = stat ~= nil and stat.type == "socket"

    if exists then
      vim.health.warn("Socket file exists but server not running: " .. socket_path)
    else
      vim.health.info("No server running on socket: " .. socket_path)
    end
  end
end

function M.check()
  vim.health.start("auto-listen")

  check_plugin_loaded()
  check_server_status()
end

return M
