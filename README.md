# nvim-auto-listen

> Automatically start a Neovim remote server on a `.nvim.socket` socket file.

## Usage

Install this plugin in your Neovim configuration. When Neovim starts, it will automatically start a remote server on a `.nvim.socket` socket file in the current working directory if one doesn't already exist.

This extension can be particularly helpful for making use of the [mcp-neovim-server](https://github.com/bigcodegen/mcp-neovim-server) MCP server. Setting `NVIM_SOCKET_PATH=.nvim.socket` will let a local editor access the local nvim session.

### Example Usage

```bash
nvim
# Server automatically starts on .nvim socket

# From another terminal, connect to the session:
nvim --server .nvim.socket --remote-send ':echo "Hello from remote session"<CR>'
```

## Configuration

You can customize the plugin behavior:

```lua
require('auto-listen').setup({
  socket = 'nvim.sock',         -- Custom socket path (optional)
  socket_xdg_runtime = true,    -- Use XDG cache directory
  socket_named = true,           -- Use directory name in socket: .nvim.<dirname>.socket
  socket_hidden = false,          -- Create visible (non-hidden) socket file
  project_root = false,          -- Disable project root detection
  autorun = false,              -- Disable automatic server start
})
```

### Options

| Option Name          | Default                                                         | Type                 | Description                                                                                                       | Env Var                         |
| -------------------- | --------------------------------------------------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `socket`             | auto-generated                                                  | string               | Full path to the socket file. If not provided, socket is auto-generated.                                          | `NVIM_AUTO_LISTEN_SOCKET`, `NVIM_SOCKET_PATH`       |
| `socket_xdg_runtime` | `false`                                                         | boolean              | Use XDG cache directory (`vim.fn.stdpath("cache")`) instead of current working directory.                         | `NVIM_AUTO_LISTEN_XDG_RUNTIME`  |
| `socket_named`       | `false`                                                         | boolean\|string      | Include name in socket filename. If `true`: use current directory name. If string: use that literal name.         | `NVIM_AUTO_LISTEN_NAMED`        |
| `socket_hidden`      | `true`                                                          | boolean              | Create hidden socket file (with leading dot).                                                                     | `NVIM_AUTO_LISTEN_HIDDEN`       |
| `project_root`       | `{"README.md", "package.json", "Cargo.toml", "pyproject.toml"}` | string[]\|false\|nil | Array of filenames to search for when determining project root. Set to `false` to disable project root detection. | `NVIM_AUTO_LISTEN_PROJECT_ROOT` |
| `autorun`            | `true`                                                          | boolean              | Automatically start server on Neovim startup.                                                                     | `NVIM_AUTO_LISTEN_AUTORUN`      |

## Socket Path Calculation

The socket file path is determined based on configuration options:

### Directory Path

```mermaid
flowchart LR
    START --> IS_SOCKET{socket?}
    IS_SOCKET -->|Yes| RETURN_SOCKET[return socket]
    IS_SOCKET -->|No| IS_XDG{xdg?}
    IS_XDG -->|Yes| XDG_CACHE[base=xdg cache]
    IS_XDG -->|No| PROJ_ROOT{project_root?}
    PROJ_ROOT -->|nil| CWD[base=cwd]
    PROJ_ROOT -->|false| DISABLED[base=cwd<br/>feature disabled]
    PROJ_ROOT -->|array| FIND_ROOT[find project root]
    XDG_CACHE --> PATH_COMPLETE
    CWD --> PATH_COMPLETE
    DISABLED --> PATH_COMPLETE
    FIND_ROOT --> PATH_COMPLETE
```

### Filename

```mermaid
flowchart LR
    START --> IS_SOCKET{socket?}
    IS_SOCKET -->|Yes| RETURN_SOCKET[return socket]
    IS_SOCKET -->|No| IS_NAMED{named?}
    IS_NAMED -->|false| BASE_NAMED[base=nvim]
    IS_NAMED -->|true| BASE_CWD[base=nvim.cwd]
    IS_NAMED -->|string| BASE_CUSTOM[base=nvim.val]
    BASE_NAMED --> IS_HIDDEN{hidden?}
    BASE_CWD --> IS_HIDDEN
    BASE_CUSTOM --> IS_HIDDEN
    IS_HIDDEN -->|Yes| ADD_DOT[file=.base.socket]
    IS_HIDDEN -->|No| NO_DOT[file=base.socket]
    ADD_DOT --> PATH_COMPLETE
    NO_DOT --> PATH_COMPLETE
```

## License

MIT
