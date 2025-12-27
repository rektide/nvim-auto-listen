# nvim-auto-listen

> Automatically start a Neovim remote server on a `.nvim.socket` socket file.

## Usage

Install this plugin in your Neovim configuration. When Neovim starts, it will automatically start a remote server on a `.nvim.socket` socket file in the current working directory if one doesn't already exist.

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
  autorun = false,              -- Disable automatic server start
})
```

### Options

- `socket`: Full path to the socket file. If not provided, socket is auto-generated.
- `socket_xdg_runtime` (boolean, default: `false`): Use XDG cache directory (`vim.fn.stdpath("cache")`) instead of current working directory.
- `socket_named` (boolean|string, default: `false`): Include name in socket filename.
  - If `true`: use current directory name (e.g., `.nvim.myproject.socket`)
  - If string: use that literal name (e.g., `.nvim.custom.socket`)
  - Note: Always uses current working directory name, even with `socket_xdg_runtime = true`. This prevents socket conflicts between different projects.
- `socket_hidden` (boolean, default: `true`): Create hidden socket file (with leading dot).
- `autorun` (boolean, default: `true`): Automatically start server on Neovim startup.

## Socket Path Calculation

The socket file path is determined based on configuration options:

### Directory Path

```mermaid
flowchart LR
    START --> IS_SOCKET{socket?}
    IS_SOCKET -->|Yes| RETURN_SOCKET[return socket]
    IS_SOCKET -->|No| IS_XDG{xdg?}
    IS_XDG -->|Yes| XDG_CACHE[base=xdg cache]
    IS_XDG -->|No| CWD[base=cwd]
    XDG_CACHE --> PATH_COMPLETE
    CWD --> PATH_COMPLETE
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
