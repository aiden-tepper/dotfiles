return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("nvim-web-devicons").get_icons()
		require("neo-tree").setup({
			window = {
				mappings = {
					["P"] = {
						"toggle_preview",
						config = {
							use_float = false,
							-- use_image_nvim = true,
							-- title = 'Neo-tree Preview',
						},
					},
				}
			}
		})
	end,
}
