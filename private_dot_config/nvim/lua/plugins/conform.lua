return {
	'stevearc/conform.nvim',
	opts = {},
	config = function()
		local conform = require('conform')
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff" },
				rust = { "rustfmt", lsp_format = "fallback", options = { default_edition = "2024" }, },
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				kdl = { "kdlfmt" },
				markdown = { "prettierd" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			require("conform").format({ async = true, lsp_format = "fallback", range = range })
		end, { range = true })
		vim.keymap.set('n', '<leader>g', ':Format<cr>')
	end,
}
