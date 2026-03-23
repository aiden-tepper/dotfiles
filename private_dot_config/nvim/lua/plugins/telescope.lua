return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					prompt_prefix = "🔍 ",
					selection_caret = "➤ ",
					sorting_strategy = "ascending",
					layout_config = { prompt_position = "top" },
				},
				pickers = {
					find_files = { hidden = true },
					live_grep = {},
					buffers = { sort_mru = true },
				},
			})

			require("telescope").load_extension("file_browser")
			require('telescope').load_extension('fzf')

			-- Key Mappings for Telescope
			vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Grep" })
			vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help" })
			vim.keymap.set("n", "<leader>f/", require("telescope.builtin").current_buffer_fuzzy_find,
				{ desc = "Current buffer fzf" })
			vim.keymap.set(
				"n",
				"<leader>ft",
				":Telescope file_browser path=%:p:h select_buffer=true hidden=true<CR>",
				{ desc = "File Browser" }
			)
			vim.keymap.set(
				"n",
				"<leader>fe",
				":Telescope frecency<CR>",
				{ desc = "Frecently Edited" }
			)
			vim.keymap.set(
				"n",
				"<leader>fq",
				require("telescope.builtin").quickfix,
				{ desc = "Quickfix" }
			)
			vim.keymap.set("n", "<leader>fp", require("telescope.builtin").planets, { desc = "Planets" })
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"nvim-telescope/telescope-frecency.nvim",
		-- install the latest stable version
		version = "*",
		config = function()
			require("telescope").load_extension "frecency"
		end,
	},
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
}
