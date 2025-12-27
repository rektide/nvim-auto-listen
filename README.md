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

| Directory Path                                                                        | Filename                                           |
| ------------------------------------------------------------------------------------- | -------------------------------------------------- | ------------------------------- | -------------------------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------- | ------------------------------------------ | ---------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| ```mermaid<br/>flowchart LR<br/>START[START] --> IS_SOCKET{socket?}<br/>IS_SOCKET --o | --> RETURN_SOCKET[return socket]<br/>IS_SOCKET --x | --> IS_XDG{xdg?}<br/>IS_XDG --o | --> XDG_CACHE[base=xdg cache]<br/>IS_XDG --x | --> CWD[base=cwd]<br/>XDG_CACHE --> PATH_COMPLETE[complete path]<br/>CWD --> PATH_COMPLETE``` | ```mermaid<br/>flowchart LR<br/>START[START] --> IS_SOCKET{socket?}<br/>IS_SOCKET --o | --> RETURN_SOCKET[return socket]<br/>IS_SOCKET --x | --> IS_NAMED{named?}<br/>IS_NAMED --x | --> BASE_NAMED[base=nvim]<br/>IS_NAMED --o | --> IS_TYPE{type?}<br/>IS_TYPE --o | --> BASE_CWD[base=nvim.cwd]<br/>IS_TYPE --s | --> BASE_CUSTOM[base=nvim.val]<br/>BASE_NAMED --> IS_HIDDEN{hidden?}<br/>BASE_CWD --> IS_HIDDEN<br/>BASE_CUSTOM --> IS_HIDDEN<br/>IS_HIDDEN --o | --> ADD_DOT[file=.base.socket]<br/>IS_HIDDEN --x | --> NO_DOT[file=base.socket]<br/>ADD_DOT --> PATH_COMPLETE[complete path]<br/>NO_DOT --> PATH_COMPLETE<br/>PATH_COMPLETE --> RETURN_SOCKET``` |

## License

MIT
