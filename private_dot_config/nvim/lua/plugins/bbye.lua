return {
	"moll/vim-bbye",
	config = function()
		vim.keymap.set('n', '<leader>q', ':Bdelete<cr>')
	end,
}
