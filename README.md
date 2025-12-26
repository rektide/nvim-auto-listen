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
  socket = 'nvim.sock',       -- Custom socket path (optional)
  socket_named = true,           -- Use directory name in socket: .nvim.<dirname>.socket
  socket_hidden = false,          -- Create visible (non-hidden) socket file
  autorun = false,              -- Disable automatic server start
})
```

### Options

- `socket`: Full path to the socket file. If not provided, socket is auto-generated.
- `socket_named` (boolean|string, default: `false`): Include name in socket filename.
  - If `true`: use current directory name (e.g., `.nvim.myproject.socket`)
  - If string: use that literal name (e.g., `.nvim.custom.socket`)
- `socket_hidden` (boolean, default: `true`): Create hidden socket file (with leading dot).
- `autorun` (boolean, default: `true`): Automatically start server on Neovim startup.

## License

MIT
