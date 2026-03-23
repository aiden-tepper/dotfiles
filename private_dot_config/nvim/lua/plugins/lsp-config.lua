return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "ts_ls", "bashls", "eslint", "taplo", "ruff" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			vim.lsp.enable("rust_analyzer")
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
			})
			lspconfig.ts_ls.setup({
			})
			lspconfig.bashls.setup({
			})
			lspconfig.eslint.setup({
				on_attach = function(client, bufnr)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						command = "EslintFixAll",
					})
				end,
			})
			lspconfig.taplo.setup({
			})
			lspconfig.ruff.setup({
			})
			lspconfig.clangd.setup({
				cmd = { "clangd-12" },
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			-- vim.keymap.set({ "n" }, "<leader>a", vim.lsp.buf.code_action, {})
			-- who needs code actions
		end,
	},
}
