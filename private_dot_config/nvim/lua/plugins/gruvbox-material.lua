return {
	"sainnhe/gruvbox-material",
	lazy = false, -- load at start
	priority = 1000, -- load first
	config = function()
		vim.g.gruvbox_material_background = "soft"
		vim.g.gruvbox_material_enable_italic = 1
		vim.g.gruvbox_material_better_performance = 1
		vim.g.gruvbox_material_transparent_background = 2
		vim.cmd.colorscheme("gruvbox-material")
		-- XXX: hi Normal ctermbg=NONE
		-- Make comments more prominent -- they are important.
		local bools = vim.api.nvim_get_hl(0, { name = "Boolean" })
		vim.api.nvim_set_hl(0, "Comment", bools)
		-- Make it clearly visible which argument we're at.
		local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
		vim.api.nvim_set_hl(
			0,
			"LspSignatureActiveParameter",
			{ fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
		)
		-- XXX
		-- Would be nice to customize the highlighting of warnings and the like to make
		-- them less glaring. But alas
		-- https://github.com/nvim-lua/lsp_extensions.nvim/issues/21
	end,
}
