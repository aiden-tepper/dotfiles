return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
		vim.api.nvim_set_hl(0, 'WhichKeyNormal', { bg = '#282828' })
		vim.api.nvim_set_hl(0, 'WhichKeyBorder', { bg = '#282828' })
		vim.api.nvim_set_hl(0, 'WhichKeyTitle', { bg = '#282828' })
		vim.api.nvim_set_hl(0, 'WhichKeySeparator', { bg = '#282828' })
		require("which-key").setup({
			preset = "helix",
		})
	end,
}
