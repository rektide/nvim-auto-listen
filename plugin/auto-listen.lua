-- Auto-load the auto-listen plugin
if vim.fn.has("nvim-0.5") == 1 then
	require("auto-listen.auto-listen").setup()
end
