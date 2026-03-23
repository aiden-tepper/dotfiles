return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		vim.lsp.enable("lua_ls")
		vim.lsp.enable("ts_ls")
		vim.lsp.enable("bash_ls")
		vim.lsp.enable("eslint")
		vim.lsp.enable("taplo")
		vim.lsp.enable("ruff")
		vim.lsp.enable("clangd")
		vim.lsp.enable("nixd")
		vim.lsp.enable("rust_analyzer")

		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
		-- vim.keymap.set({ "n" }, "<leader>a", vim.lsp.buf.code_action, {})
		-- who needs code actions
	end,
}
