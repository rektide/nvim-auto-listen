# nvim-auto-listen

> Automatically start a Neovim remote server on a `.nvim.socket` socket.

## Usage

Install this plugin in your Neovim configuration. When Neovim starts, it will automatically start a remote server on a `.nvim.socket` socket file in the current directory if one doesn't already exist.

### Example Usage

```bash
nvim
# Server automatically starts on .nvim socket

# From another terminal, connect to the session:
nvim --server .nvim.socket --remote-send ':echo "Hello from remote session"<CR>'
```

## Configuration

You can customize the socket path:

```lua
require('nvim-session.auto-listen').setup({
  socket = 'nvim.sock'
})
```

## License

MIT
