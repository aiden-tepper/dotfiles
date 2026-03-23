return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"c",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"rust",
				"python",
				"javascript",
				"html",
				"bash",
				"cpp",
				"dockerfile",
				"fish",
				"gitignore",
				"go",
				"graphql",
				"helm",
				"json",
				"jq",
				"make",
				"markdown",
				"proto",
				"sql",
				"starlark",
				"toml",
				"tsx",
				"typescript",
			},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
